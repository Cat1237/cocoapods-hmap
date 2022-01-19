module HMap
  module PBXHelper
    PBX_GROUP = '<group>'
    PBX_SOURCE_ROOT = 'SOURCE_ROOT'
    private_constant :PBX_GROUP, :PBX_SOURCE_ROOT
    def self.get_groups(xct)
      groups = xct.referrers.select { |e| e.is_a?(Constants::PBXGroup) } || []
      groups += groups.flat_map { |g| get_groups(g) }
      groups.compact
    end

    def self.group_paths(xct)
      gs = get_groups(xct).reverse
      ps = gs.map do |g|
        s_hash = g.instance_variable_get('@simple_attributes_hash')
        s_hash['path'] unless s_hash.nil? && s_hash['sourceTree'] == PBX_GROUP
      end.compact
      File.join(*ps)
    end

    def self.uses_swift?(target)
      source_files = target.build_phases.flat_map do |phase|
        phase.files if phase.is_a?(Constants::PBXSourcesBuildPhase)
      end.compact
      source_files.any? do |file|
        path = file.file_ref.instance_variable_get('@simple_attributes_hash')['path'] || ''
        File.extname(path) == '.swift'
      end
    end

    def self.build_as_framework?(target)
      target.symbol_type == :framework if target.respond_to?(:symbol_type)
    end

    def self.defines_module?(target)
      return true if build_as_framework?(target)

      bus = target.build_configuration_list.build_configurations.map do |bu|
        bu.instance_variable_get('@simple_attributes_hash')['buildSettings'] || {}
      end

      bus.any? { |s| s['DEFINES_MODULE'] == 'YES' }
    end

    def self.projects(*p_paths)
      return if p_paths.empty?

      p_paths.flat_map do |pj|
        project = Xcodeproj::Project.open(pj)
        p_path = File.dirname(project.path)
        project.root_object.project_references.map do |sp|
          ff = sp[:project_ref]
          f_hash = ff.instance_variable_get('@simple_attributes_hash')
          g_path = PBXHelper.group_paths(ff) if f_hash['sourceTree'] == PBX_GROUP
          path = f_hash['path'] || ''
          full_path = File.join(p_path, g_path || '', path)
          Xcodeproj::Project.open(full_path)
        end << project
      end
    end

    def self.project_references(project)
      return if project.nil?

      p_path = File.dirname(project.path)
      project.root_object.project_references.map do |sp|
        ff = sp[:project_ref]
        path = ff.instance_variable_get('@simple_attributes_hash')['path'] || ''
        full_path = File.join(p_path, path)
        Xcodeproj::Project.open(full_path)
      end
    end
  end
end
