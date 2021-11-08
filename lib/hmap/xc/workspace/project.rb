# frozen_string_literal: true

require 'hmap/xc/workspace/project_helper'
require 'hmap/xc/target/target'

module HMap
  HEADER_FILES_EXTENSIONS = %w[.h .hh .hpp .ipp .tpp .hxx .def .inl .inc .pch]

  class Project
    include HMap::Project::Helper

    attr_reader :project, :workspace

    def initialize(project, workspace)
      @project = project
      @workspace = workspace
    end

    def platforms
      return @platforms if defined? @platforms

      build_configurations = project.build_configuration_list.build_configurations
      build_configurations += project.targets.flat_map do |target|
        target.build_configuration_list.build_configurations
      end 

      ps = build_configurations.flatten.each_with_object({}) do |configuration, sum|
        bs = configuration.build_settings
        d_t = []
        d_t << :osx unless bs['MACOSX_DEPLOYMENT_TARGET'].nil?
        d_t << :ios unless bs['IPHONEOS_DEPLOYMENT_TARGET'].nil?
        d_t << :watchos unless bs['WATCHOS_DEPLOYMENT_TARGET'].nil?
        d_t << :tvos unless bs['TVOS_DEPLOYMENT_TARGET'].nil?
        sum[configuration.name] ||= []
        sum[configuration.name] += d_t unless d_t.empty?
      end

      @platforms = ps.flat_map do |key, value|
        Platform.new_from_platforms(key, value.uniq)
      end
    end
    
    def targets
      return @targets if defined?(@targets)

      project_dir = project.project_dir
      
      h_ts = project.targets.map do |target|
        next if target.is_a?(Constants::PBXAggregateTarget)
        
        name = target.name
        headers = target.build_phases.flat_map do |phase|
          next unless phase.is_a?(Constants::PBXHeadersBuildPhase)

          phase.files.flat_map do |file|
            ff = file.file_ref
            f_path = ff.instance_variable_get('@simple_attributes_hash')['path'] || ''
            g_path = PBXHelper.group_paths(ff)
            header_entry(project_dir, g_path, f_path, file)
          end
        end.compact
        Target.new(headers, target, self)
      end.compact
      @targets = h_ts || []
    end

    def write_hmapfile!
      hmap_writer = BuildSettingsWriter.new(platforms, context)
      types = %i[all_non_framework_target_headers project_headers all_target_headers all_product_headers]
      datas = headers_hash(*types)
      hmap_writer.write_or_symlink(nil, datas, %i[all_product_headers])
      targets.each(&:write_hmapfile!)
    end

    def save_hmap_settings!
      targets.each(&:save_hmap_settings!)
    end

    def remove_hmap_settings!
      targets.each(&:remove_hmap_settings!)
    end

    private

    def header_entry(project_dir, group, file, xc)
      settings_h = xc.instance_variable_get('@simple_attributes_hash') || {}
      settings = settings_h['settings'] || {}
      attributes = settings['ATTRIBUTES']
      full_path = File.expand_path(File.join(project_dir, group, file))
      extra_headers = []
      extra_headers << File.join(group, file)
      extra_headers << File.join(file)
      extra_headers.uniq!
      types = %i[Public Private Project]
      attributes = 'Project' if attributes.nil?
      ts = types.select { |type| attributes.include?(type.to_s) }
      ts.map { |t| HeaderEntry.new(full_path, extra_headers, t) }
    end

    def entrys
      return @entrys if defined?(@entrys)

      project_dir = project.project_dir
      @entrys = project.objects_by_uuid.flat_map do |_uuid, ff|
        next unless ff.is_a?(Constants::PBXFileReference)

        f_path = ff.instance_variable_get('@simple_attributes_hash')['path'] || ''
        next unless HEADER_FILES_EXTENSIONS.include?(File.extname(f_path))

        builds = ff.referrers.select { |e| e.is_a?(Constants::PBXBuildFile) } || []
        g_path = PBXHelper.group_paths(ff)
        if builds.empty?
          header_entry(project_dir, g_path, f_path, nil)
        else
          builds.flat_map { |bf| header_entry(project_dir, g_path, f_path, bf) }
        end
      end.compact
    end
  end
end
