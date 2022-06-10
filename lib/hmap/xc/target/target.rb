# frozen_string_literal: true

require 'hmap/xc/target/build_setting'
require 'hmap/xc/target/target_helper'
require 'hmap/xc/target/xcconfig_helper'

module HMap
  class Target
    include HMap::Target::Helper

    attr_reader :entrys, :target, :project
    attr_accessor :xcconfig_paths

    def initialize(entrys, target, project)
      @entrys = entrys || []
      @target = target
      @project = project
      @xcconfig_paths = []
    end

    def platforms
      project.platforms
    end

    def write_hmapfile!
      datas = headers_hash(:own_target_headers)
      build_settings = BuildSettingsWriter.new(platforms, context)
      build_settings.write_or_symlink(project.context.hmap_root, datas, Constants::HMAP_FILE_TYPE)
    end

    def save_hmap_settings!
      build_setting_paths.each do |path|
        settings = Constants.instance.hmap_build_settings
        XcodeprojHelper.new(path).add_build_settings_and_save(settings, use_origin: Resolver.instance.use_origin)
      end
    end

    def remove_hmap_settings!
      build_setting_paths.each { |path| HMap::XcodeprojHelper.new(path).remove_build_settings_and_save }
    end

    private

    def build_setting_paths
      return @build_setting_paths if defined?(@build_setting_paths)

      @build_setting_paths = xcconfig_paths.map do |path|
        xc = XCConfig.new(path)
        inc = xc.includes_paths
        path if inc.empty? || project.workspace.xcconfig_paths.none? { |pa| inc.include?(pa) }
      end.compact
    end

    # def xcconfig_paths
    #   return @xcconfig_paths if defined?(@xcconfig_paths)

    #   @xcconfig_paths = target.build_configurations.flat_map do |configuration|
    #     if configuration.is_a?(Constants::XCBuildConfiguration)
    #       bcr = configuration.base_configuration_reference
    #       unless bcr.nil?
    #         s_path = PBXHelper.group_paths(bcr)
    #         x = bcr.instance_variable_get('@simple_attributes_hash')['path'] || ''
    #         path = File.expand_path(File.join(project.project_dir, s_path, x))
    #         xc = XCConfig.new(path)
    #         inc = xc.includes_paths
    #         path if inc.empty? || project.workspace.xcconfig_paths.none? { |pa| inc.include?(pa) }
    #       end
    #     end
    #   end.compact

    #   @xcconfig_paths = target.build_configuration_list.build_configurations.flat_map do |configuration|
    #     if configuration.is_a?(Constants::XCBuildConfiguration)
    #       bcr = configuration.base_configuration_reference
    #       # if bcr.nil?
    #       #   ab_path = Pathname(project.project_dir + "hmap-#{target_name}.#{configuration.name}.xcconfig")
    #       #   File.new(ab_path, 'w') unless ab_path.exist?
    #       #   xc_ref = target.project.new_file(ab_path)
    #       #   configuration.base_configuration_reference = xc_ref
    #       #   target.project.save
    #       #   ab_path
    #       # else
    #       unless bcr.nil?
    #         s_path = PBXHelper.group_paths(bcr)
    #         x = bcr.instance_variable_get('@simple_attributes_hash')['path'] || ''
    #         File.expand_path File.join(project.project_dir, s_path, x)
    #       end
    #     end
    #   end.compact
    # end
  end
end
