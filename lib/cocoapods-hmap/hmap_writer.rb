# frozen_string_literal: true

require 'cocoapods'

module Pod
  Validator.class_eval do
    def results=(v)
      @results = v
    end
  end
end

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
  HEAD_SEARCH_I = '-I'
  HEAD_SEARCH_IQUOTE = '-iquote'
  # build setting HEAD_SEARCH_PATHs
  HEAD_SEARCH_PATHS = 'HEADER_SEARCH_PATHS'

  # Helper module which returns handle method from MapFileWriter.
  class MapFileWriter
    # @param save_origin_header_search_paths save_origin_header_search_paths
    # @param clean_hmap clean up all hmap setup
    def initialize(save_origin_header_search_paths, clean_hmap)
      @save_origin_header_search_paths = save_origin_header_search_paths
      @hmap_saver = HMapSaver.new
      @hmap_saver_iquote = HMapSaver.new
      create_mapfile(clean_hmap)
    end

    private

    # Integrates the projects mapfile associated
    # with the App project and Pods project.
    #
    # @param  [clean] clean hmap dir @see #podfile
    # @return [void]
    #
    def create_mapfile(clean)
      puts "Current hmap files dir: #{Helper::Pods.hmap_files_dir}"
      puts "Current vfs files dir: #{Helper::Pods.vfs_files_dir}"
      analyze = PodsSpecification.instance.analyze
      targets = analyze.targets
      pod_targets = analyze.pod_targets
      return if BuildSettingHelper.clean_hmap(clean, targets, pod_targets)

      merge_all_pods_target_headers_mapfile(pod_targets)
      merge_all_target_public_headers_mapfile(targets)
    end

    def from_header_mappings(target, type = :source_files)
      headers = Helper::Pods.header_mappings(target, type)
      headers[HEAD_SEARCH_IQUOTE].each { |value| @hmap_saver_iquote.add_to_buckets(*value) }
      headers[HEAD_SEARCH_I].each { |value| @hmap_saver.add_to_buckets(*value) }
    end

    def merge_all_target_public_headers_mapfile(targets)
      names = targets.map do |target|
        hmap_name = "all-public-#{target.name}"
        create_hmap_vfs_files(target.pod_targets, hmap_name, :public_header_files)
        hmap_name
      end
      BuildSettingHelper.change_other_c_flags_xcconfig_build_settings(names, targets,
                                                  save_origin: @save_origin_header_search_paths)
    end

    def merge_all_pods_target_headers_mapfile(pod_targets)
      hmap_name = 'all-pods-all-header'
      create_hmap_vfs_files(pod_targets, hmap_name, :source_files)
      BuildSettingHelper.change_other_c_flags_xcconfig_build_settings([hmap_name], pod_targets,
                                                  save_origin: @save_origin_header_search_paths)
    end

    # Cteate hmap files and vfs files
    #
    # @param [pod_targets] Pods project all target @see Pod#PodTarget
    # @param [hmap_name] -I hmap file name and -iquote hmap file name
    # @param [hmap_type] hmap file contains pod targets header type
    #
    def create_hmap_vfs_files(pod_targets, hmap_name, hmap_type = :public_header_files)
      pod_targets.each { |target| from_header_mappings(target, hmap_type) }
      Helper::Pods.write_vfs_yaml(pod_targets)
      write_hmap_files(*Helper::Pods.hmap_files_paths(hmap_name))
    end

    def write_hmap_files(hmap_path_i, hmap_path_iquote)
      print "\t - Save hmap file to path: "
      puts hmap_path_i.to_s.yellow
      print "\t - Save hmap file to path: "
      puts hmap_path_iquote.to_s.yellow
      @hmap_saver.write_to(hmap_path_i)
      @hmap_saver_iquote.write_to(hmap_path_iquote)
    end
  end
end
