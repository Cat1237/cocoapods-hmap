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
      hmap_s = 'headers'
      hmap_s = "#{HMMAP_TYPE[hmap_type]}_#{hmap_s}" unless hmap_type == :source_files
      headers = target.header_mappings_by_file_accessor.keys.flat_map(&hmap_s.to_sym)
      s_headers = Helper::Pods.pod_target_source_header_map(target, hmap_type)
      headers.each_with_object(buckets) do |header_f, sum|
        keys = header_perfix(target, header_f, s_headers)
        sum[0] += header_to_hash(keys, header_h, sum[0].length, sum[1])
      end
    end

    def header_perfix(target, file, s_headers)
      key = file.basename.to_s
      project_name = "#{target.project_name}/#{file.basename}"
      product_module_name = "#{target.product_module_name}/#{file.basename}"
      perfix = "#{file.dirname}/"
      keys = [key, project_name, product_module_name] + (s_headers[key].nil? ? [] : s_headers[key])
      keys.compact.uniq.inject([]) do |sum, name|
        sum << [name, perfix, key]
      end
    end

    def header_to_hash(keys, headers, index, buckets)
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
        hmap_name = "All-Pods-Public-#{target.name}-hmap.hmap"
        single_target_mapfile(target.pod_targets, hmap_dir, hmap_name, method)
        change_target_xcconfig_header_search_path([hmap_name], true, *targets)
      end
    end

    def merge_all_pods_target_headers_mapfile(pod_targets, hmap_dir)
      method = method(:from_header_mappings_by_file_accessor)
      hmap_name = 'All-Pods-All-Header-hmap.hmap'
      single_target_mapfile(pod_targets, hmap_dir, hmap_name, method, :source_files)
      change_target_xcconfig_header_search_path([hmap_name], true, *pod_targets)
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
