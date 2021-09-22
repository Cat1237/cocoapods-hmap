# frozen_string_literal: true

# require 'cocoapods'

module HMap
  # Helper module which returns handle method from MapFileWriter.
  class MapFileWriter
    # @param save_origin_header_search_paths save_origin_header_search_paths
    # @param clean_hmap clean up all hmap setup
    # @param use_build_in_headermap option use Xcode header map
    def initialize(save_origin_build_setting, clean_hmap, allow_targets, use_build_in_headermap: true)
      @allow_targets = allow_targets
      @save_origin_build_setting = save_origin_build_setting
      @use_build_in_headermap = use_build_in_headermap
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
      analyze = PodsSpecification.instance.analyze
      targets = analyze.targets
      pod_targets = analyze.pod_targets
      return if Pods.clean_hmap_setting(clean, targets, pod_targets)

      merge_all_pods_target_headers_mapfile(pod_targets) unless @use_build_in_headermap
      merge_all_target_public_headers_mapfile(targets)
    end

    def vfs_from_target(target, helper)
      return unless target.build_as_framework?

      spec_path = target.specs.map(&:defined_in_file).uniq.first
      platforms = Pods.target_support_platforms(spec_path)
      headers = Pods.headers_mappings_by_file(target).flat_map { |h| h }
      helper.add_framework_entry(target.user_build_configurations.keys,
                                 platforms, target.name, target.product_module_name, target.support_files_dir, headers)
    end

    def hmap_from_header_mappings(target, helper, type = :source_files)
      Pods.headers_mappings_by_file_accessor(target, type).each do |key, headers|
        helper.header_mappings(headers, Pod::Config.instance.sandbox.root.join(target.headers_sandbox),
                               target.product_basename, key)
      end
    end

    def hmap_vfs_from_target(target, helper, type = :source_files)
      vfs_from_target(target, helper)
      hmap_from_header_mappings(target, helper, type)
    end

    def merge_all_target_public_headers_mapfile(targets)
      helper = HMapHelper.new(Pods.hmap_files_dir)
      targets.each do |target|
        hmap_name = target.name.to_s
        target.pod_targets.each do |p_target|
          hmap_vfs_from_target(p_target, helper, :public_header_files)
        end
        change_xcconfig_other_c_flags_and_save(target, helper, hmap_name, save_origin: @save_origin_build_setting)
        helper.write_hmap_vfs_to_paths(hmap_name)
      end
    end

    def merge_all_pods_target_headers_mapfile(pod_targets)
      helper = HMapHelper.new(Pods.hmap_files_dir)
      hmap_name = 'all-pods'
      pod_targets.each do |target|
        hmap_vfs_from_target(target, helper)
        change_xcconfig_other_c_flags_and_save(target, helper, hmap_name, save_origin: @save_origin_build_setting)
      end
      helper.write_hmap_vfs_to_paths(hmap_name)
    end

    # Cteate hmap files and vfs files
    #
    # @param [target] Pods project target @see Pod#PodTarget
    # @param [hmap_helper] @see HMap#HMapHelper
    # @param [hmap_name] hmap file contains pod targets header type
    # @param [save_origin] save or not save origin build setting
    def change_xcconfig_other_c_flags_and_save(target, hmap_helper, hmap_name, save_origin: false)
      save_origin = true if @allow_targets.include?(target.name)
      setting = hmap_helper.xcconfig_header_setting(target.build_as_framework?, Pods.pods_hmap_files_dir, hmap_name)
      Pods.xcconfig_path_from(target) do |xcconfig|
        XcodeprojHelper.new(xcconfig).change_xcconfig_other_c_flags_and_save(setting, save_origin: save_origin)
      end
    end
  end
end
