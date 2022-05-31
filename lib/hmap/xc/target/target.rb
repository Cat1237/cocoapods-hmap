# frozen_string_literal: true

require 'hmap/xc/target/build_setting'
require 'hmap/xc/target/target_helper'
require 'hmap/xc/target/xcconfig_helper'

module HMap
  class Target
    include HMap::Target::Helper

    attr_reader :entrys, :target, :project

    def initialize(entrys, target, project)
      @entrys = entrys || []
      @target = target
      @project = project
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
      xcconfig_paths.each do |path|
        settings = Constants.instance.hmap_build_settings(build_as_framework?)
        XcodeprojHelper.new(path).add_build_settings_and_save(settings, use_origin: Resolver.instance.use_origin)
      end
    end

    def remove_hmap_settings!
      xcconfig_paths.each { |path| HMap::XcodeprojHelper.new(path).remove_build_settings_and_save }
    end

    private

    def xcconfig_paths
      return @xcconfig_paths if defined?(@xcconfig_paths)

      @xcconfig_paths = target.build_configuration_list.build_configurations.flat_map do |configuration|
        if configuration.is_a?(Constants::XCBuildConfiguration)
          bcr = configuration.base_configuration_reference
          unless bcr.nil?
            s_path = PBXHelper.group_paths(bcr)
            x = bcr.instance_variable_get('@simple_attributes_hash')['path'] || ''
            File.expand_path File.join(project.project_dir, s_path, x)
          end
        end
      end.compact
      #   @xcconfig_paths = TargetConfiguration.new_from_xc(target, project.project_dir).map do |c|
      #     c.xcconfig_path unless c.xcconfig_path.nil?
      #   end.compact
      # @xcconfig_paths = bc.map(&:xcconfig_path).compact
      # xc_type = 'XCConfigurationList'
      # xcs = target.build_configuration_list.build_configurations
      # @xcconfig_paths = xcs.map do |xc|
      #   if xc.isa == xc_type
      #     xc_path = xc.instance_variable_get('@simple_attributes_hash')['path'] || ''
      #     { xc => File.join(project.project_dir, xc_path) }
      #   else
      #     # ab_path = Pathname(project.project_dir + "hmap-#{name}.#{xc.name}.xcconfig")
      #     # File.new(ab_path, 'w') unless ab_path.exist?
      #     # xc_ref = target.project.new_file(ab_path)
      #     # xc.base_configuration_reference = xc_ref
      #     # target.project.save
      #     # ab_path
      #   end
      # end
    end
  end
end
