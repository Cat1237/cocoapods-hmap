require 'hmap/xc/header_type'
require 'hmap/xc/context'

module HMap
  class Project
    module Helper
      include HMap::HeaderType

      define_method(:all_product_headers) do
        return @all_product_headers if defined? @all_product_headers

        @all_product_headers = targets.each_with_object({}) do |target, sum|
          next if target.all_product_headers.nil?

          sum.merge!(target.all_product_headers) { |_, oldval, newval| newval + oldval }
        end
      end

      define_method(:all_non_framework_target_headers) do
        return @all_non_framework_target_headers if defined?(@all_non_framework_target_headers)

        @all_non_framework_target_headers = targets.inject({}) do |sum, entry|
          sum.merge!(entry.all_non_framework_target_headers || {}) { |_, v1, _| v1 }
        end
      end

      # all_targets include header full module path
      define_method(:all_target_headers) do
        return @all_target_headers if defined?(@all_target_headers)

        @all_target_headers = workspace.all_target_headers
      end

      define_method(:project_headers) do
        return @project_headers if defined?(@project_headers)

        @project_headers = targets.inject({}) do |sum, entry|
          sum.merge!(entry.project_headers) { |_, v1, _| v1 }
        end
      end

      def project_references
        return @project_references if defined? @project_references

        project_references = PBXHelper.project_references(project)
        @project_references = project_references.map { |pr| Project.new(pr, workspace) }
      end

      def temp_name
        "#{project_name}.build"
      end

      def build_dir() end

      def project_name
        project.root_object.name
      end

      def project_dir
        project.project_dir
      end

      def build_root
        workspace.build_root
      end

      def temp_dir
        File.join(workspace.obj_root, temp_name)
      end

      def hmap_root
        File.join(workspace.hmap_root, temp_name)
      end

      def build_data_dir
        Constants::XC_BUILD_DATA
      end

      def context
        HMap::Context.new(build_root,
                          temp_dir,
                          File.join(hmap_root, build_data_dir),
                          '',
                          build_dir)
      end
    end
  end
end
