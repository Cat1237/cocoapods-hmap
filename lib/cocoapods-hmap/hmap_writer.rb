# frozen_string_literal: true

require 'cocoapods'

module HMap
  # mapfile dir name
  # @api private
  HMAP_DIR = 'HMap'
  # mapfile type
  # @note public => pods public,
  # private => pods private,
  # all => public + private + extra.
  # @api private
  HMMAP_TYPE = {
    public_header_files: 'public',
    private_header_files: 'private',
    source_files: 'all'
  }.freeze

  # build setting HEAD_SEARCH_PATHs
  HEAD_SEARCH_PATHS = 'HEADER_SEARCH_PATHS'
  # Helper module which returns handle method from MapFileWriter.
  class MapFileWriter
    # @param save_origin_header_search_paths save_origin_header_search_paths
    # @param clean_hmap clean up all hmap setup
    def initialize(save_origin_header_search_paths, clean_hmap)
      config = Pod::Config.instance
      analyze = Helper::Pods.pod_analyze(config)
      hmap_dir = hmap_dir(config)
      targets = analyze.targets
      pod_targets = analyze.pod_targets
      clean_hmap(clean_hmap, hmap_dir, targets, pod_targets)
      return if clean_hmap

      @save_origin_header_search_paths = save_origin_header_search_paths
      gen_mapfile(targets, pod_targets, hmap_dir)
    end

    private

    def hmap_dir(config)
      puts "Current podfile dir: #{config.installation_root}"
      hmap_dir = File.join(config.sandbox.headers_root, HMAP_DIR)
      puts "Current HMap dir: #{hmap_dir}"
      hmap_dir
    end

    def clean_hmap(clean_hmap, hmap_dir, *targets)
      return unless clean_hmap

      FileUtils.rm_rf(hmap_dir)
      targets.each do |tg|
        Utils.clean_target_build_setting(tg, HEAD_SEARCH_PATHS)
      end
    end

    def gen_mapfile(targets, pod_targets, hmap_d)
      puts('Inspecting targets to integrate ')
      merge_all_pods_target_headers_mapfile(pod_targets, hmap_d)
      merge_all_target_public_mapfile(targets, hmap_d)
      create_each_target_mapfile(pod_targets, hmap_d)
    end

    def from_header_mappings_by_file_accessor(header_h, buckets, target, hmap_type)
      hmap_t = hmap_type == :source_files ? 'headers' : "#{HMMAP_TYPE[hmap_type]}_headers"
      valid_accessors = target.file_accessors.reject { |fa| fa.spec.non_library_specification? }
      headers = valid_accessors.each_with_object({}) do |file_accessor, sum|
        # Private headers will always end up in Pods/Headers/Private/PodA/*.h
        # This will allow for `""` imports to work.
        type_header = file_accessor.method(hmap_t.to_sym).call
        Helper::Pods.header_mappings(file_accessor, type_header, target).each do |key, value|
          sum[key] ||= []
          sum[key] += value
        end
      end

      if target.build_as_framework?
        headers[target.prefix_header_path] = [target.prefix_header_path.basename]
        headers[target.umbrella_header_path] = [target.umbrella_header_path.basename]
      end
      headers.each_with_object(buckets) do |header_f, sum|
        keys = header_perfix(*header_f)
        sum[0] += header_to_hash(keys, header_h, *sum)
      end
    end

    def header_perfix(file, keys)
      perfix = "#{file.dirname}/"
      suffix = file.basename.to_s
      keys.inject([]) do |sum, name|
        sum << [name.to_s, perfix, suffix]
      end
    end

    def header_to_hash(keys, headers, index, buckets)
      index = index.length
      keys.inject('') do |sum, bucket|
        buckte = HMapBucketStr.new(*bucket)
        string_t = buckte.bucket_to_string(headers, index + sum.length)
        buckets.push(buckte)
        sum + string_t
      end
    end

    def merge_all_target_public_mapfile(targets, hmap_dir)
      method = method(:from_header_mappings_by_file_accessor)
      targets.each do |target|
        hmap_name = "All-Public-#{target.name}-hmap.hmap"
        single_target_mapfile(target.pod_targets, hmap_dir, hmap_name, method)
        change_target_xcconfig_header_search_path([hmap_name], true, target)
      end
    end

    def merge_all_pods_target_headers_mapfile(pod_targets, hmap_dir)
      method = method(:from_header_mappings_by_file_accessor)
      hmap_name = 'All-Pods-All-Header-hmap.hmap'
      single_target_mapfile(pod_targets, hmap_dir, hmap_name, method, :source_files)
      change_target_xcconfig_header_search_path([hmap_name], false, *pod_targets)
    end

    def create_each_target_mapfile(pod_targets, hmap_dir)
      pod_targets.each do |target|
        HMMAP_TYPE.flat_map do |key, value|
          hmap_name = "#{target.name}-#{value}-hmap.hmap"
          method = method(:from_header_mappings_by_file_accessor)
          single_target_mapfile([target], File.join(hmap_dir, target.name), hmap_name, method, key)
          "#{target.name}/#{hmap_name}" if key == :source_files
        end.compact
        # change_target_xcconfig_header_search_path(hmap_h, false, target)
      end
    end

    def single_target_mapfile(pod_targets, hmap_dir, hmap_name, headers, hmap_type = :public_header_files)
      hmap_path = Pathname(File.join(hmap_dir, hmap_name))
      header_h = {}
      buckets = pod_targets.inject(["\0", []]) do |bucktes, target|
        headers.call(header_h, bucktes, target, hmap_type)
      end
      wirte_mapfile_to_path(hmap_path, buckets)
    end

    def wirte_mapfile_to_path(hmap_path, buckets)
      print "\t - save hmap file to path:"
      puts hmap_path.to_s.yellow
      MapFile.new(*buckets).write(hmap_path)
    end

    def change_target_xcconfig_header_search_path(hmap_h, use_headermap, *targets)
      Utils.target_xcconfig_path(targets) do |xc|
        Utils.chang_xcconfig_header_search_path(xc, hmap_h, use_headermap: use_headermap,
                                                            save_origin: @save_origin_header_search_paths)
      end
    end
  end
end
