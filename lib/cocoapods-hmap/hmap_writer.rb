# frozen_string_literal: true

require 'cocoapods'

module HMap
  # mapfile dir name
  # @api private
  HMAP_DIR = 'HMap'

  # mapfile type
  # @note public => pods public,
  # private => pods private.
  # @api private
  HMMAP_TYPE = {
    PUBLIC: 'public',
    PRIVATE: 'private'
  }.freeze

  

  # build setting HEAD_SEARCH_PATHs
  HEAD_SEARCH_PATHS = 'HEADER_SEARCH_PATHS'
  # Helper module which returns handle method from MapFileWriter.
  class MapFileWriter
  
    def initialize(path = nil)
      unless path.nil?
        raise ArgumentError, "#{path}: no such dir" unless File.directory?(path)
        Dir.chdir(path) 
      end
      config = Pod::Config.instance
      analyze = Utils.pod_analyze(config)
      puts "Current podfile dir: #{config.installation_root}"
      hmap_dir = File.join(config.sandbox.headers_root, HMAP_DIR)
      targets = analyze.targets
      pod_targets = analyze.pod_targets
      puts('Inspecting targets to integrate ')
      merge_all_target_public_mapfile(targets, hmap_dir)
      create_each_target_mapfile(pod_targets, hmap_dir)
    end

    private

    def from_header_mappings_by_file_accessor(header_h, buckets, target, hmap_type)
      m_s = "#{HMMAP_TYPE[hmap_type]}_headers".to_sym
      headers = target.header_mappings_by_file_accessor.keys.flat_map(&m_s)
      headers.each_with_object(buckets) do |header, sum|
        sum[0] += header_to_hash(target.name, header, header_h, sum[0].length, sum[1])
      end
    end

    def header_to_hash(dir, file, headers, index, buckets)
      key = file.basename.to_s
      key1 = "#{dir}/#{file.basename}"
      perfix = "#{file.dirname}/"
      [[key, perfix, key], [key1, perfix, key]].inject('') do |sum, bucket|
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
        change_target_xcconfig_header_search_path([hmap_name], *targets)
      end
    end

    def create_each_target_mapfile(pod_targets, hmap_dir)
      pod_targets.each do |target|
        hmap_h = []
        HMMAP_TYPE.each do |key, value|
          hmap_name = "#{target.name}-#{value}-hmap.hmap"
          method = method(:from_header_mappings_by_file_accessor)
          hmap_h << hmap_name
          single_target_mapfile([target], File.join(hmap_dir, target.name), hmap_name, method, key)
        end
        change_target_xcconfig_header_search_path(hmap_h, target)
      end
    end

    def single_target_mapfile(pod_targets, hmap_dir, hmap_name, headers, hmap_type = :PUBLIC)
      hmap_path = Pathname(File.join(hmap_dir, hmap_name))
      header_h = {}
      buckets = pod_targets.inject(["\0", []]) do |bucktes, target|
        headers.call(header_h, bucktes, target, hmap_type)
      end
      wirte_mapfile_to_path(hmap_path, buckets)
    end

    def wirte_mapfile_to_path(hmap_path, buckets)
      print "\t - save hmap file to path:"
      puts "#{hmap_path}".yellow
      MapFile.new(*buckets).write(hmap_path)
    end

    def change_target_xcconfig_header_search_path(hmap_h, *targets)
      targets.each do |target|
        raise ClassIncludedError.new(target.class, Pod::Target) unless target.is_a?(Pod::Target)

        config_h = Pod::Target.instance_method(:build_settings).bind(target).call
        config_h.each_key do |configuration_name|
          chang_target_xcconfig_header_search_path(target, configuration_name, hmap_h)
        end
      end
    end

    def chang_target_xcconfig_header_search_path(target, configuration_name, hmap_h)
      hmap_header_serach_paths = hmap_h.inject('') do |sum, hmap_n|
        hmap_pod_root_path = "${PODS_ROOT}/Headers/#{HMAP_DIR}/#{hmap_n}"
        sum + "\"#{hmap_pod_root_path}\" "
      end
      xcconfig = target.xcconfig_path(configuration_name)
      Utils.save_build_setting_to_xcconfig(xcconfig, hmap_header_serach_paths, HEAD_SEARCH_PATHS)
    end
  end
end
