require 'hmap/xc/target/target_context'

module HMap
  class Target
    module Helper
      include HMap::HeaderType

      define_method(:all_product_headers) do
        return @all_product_headers if defined? @all_product_headers

        public_headers = public_entrys.map(&:path)
        private_headers = private_entrys.map(&:path)
        @all_product_headers = TargetVFS.new(public_headers, private_headers, platforms, context).vfs_entrys
      end

      define_method(:all_non_framework_target_headers) do
        return if build_as_framework?

        return @all_non_framework_target_headers if defined? @all_non_framework_target_headers

        p_h = public_entrys + private_entrys
        @all_non_framework_target_headers = p_h.inject({}) do |sum, entry|
          sum.merge!(entry.full_module_buckets(product_name)) { |_, v1, _| v1 }
        end
      end

      # all_targets include header full module path
      define_method(:all_target_headers) do
        return @all_target_headers if defined? @all_target_headers

        p_h = public_entrys + private_entrys
        @all_target_headers = p_h.inject({}) do |sum, entry|
          sum.merge!(entry.module_buckets(product_name)) { |_, v1, _| v1 }
          sum.merge!(entry.full_module_buckets(product_name)) { |_, v1, _| v1 }
        end
      end

      define_method(:project_headers) do
        return @project_headers if defined? @project_headers

        p_h = public_entrys + private_entrys
        hs = p_h.inject({}) do |sum, entry|
          sum.merge!(entry.module_buckets(product_name)) { |_, v1, _| v1 }
        end
        @project_headers = project_entrys.inject(hs) do |sum, entry|
          sum.merge!(entry.project_buckets_extra) { |_, v1, _| v1 }
        end
      end

      define_method(:own_target_headers) do
        return @own_target_headers if defined? @own_target_headers

        headers = public_entrys + private_entrys
        hs = headers.inject({}) do |sum, entry|
          sum.merge!(entry.module_buckets(product_name)) { |_, v1, _| v1 }
        end
        @own_target_headers = project_entrys.inject(hs) do |sum, entry|
          sum.merge!(entry.project_buckets) { |_, v1, _| v1 }
          sum.merge!(entry.full_module_buckets(product_name)) { |_, v1, _| v1 }
        end
      end

      def build_root
        project.build_root
      end

      def hmap_root
        project.hmap_root
      end

      def target_name
        target.name
      end

      def product_name
        product_name = target.build_settings(target.build_configurations.first.name)['PRODUCT_NAME']
        return target_name.gsub(/-/, '_') if product_name.nil? || product_name.include?('TARGET_NAME')

        product_name
      end

      def full_product_name
        target.product_reference.instance_variable_get('@simple_attributes_hash')['path'] || ''
      end

      def temp_name
        "#{target_name}.build"
      end

      def temp_dir
        project.temp_dir
      end

      def build_dir
        return @build_dir if defined?(@build_dir)

        b_d = build_setting_paths.none? { |path| XCConfig.new(path).attributes[Constants::CONFIGURATION_BUILD_DIR].nil? }
        @build_dir = target_name if b_d
      end

      def app_target?
        Xcodeproj::Constants::PRODUCT_UTI_EXTENSIONS[target.symbol_type] == 'app'
      end

      def build_as_framework?
        PBXHelper.build_as_framework?(target)
      end

      def build_as_framework_swift?
        uses_swift? && build_as_framework?
      end

      def uses_swift?
        return @uses_swift if defined?(@uses_swift)

        @uses_swift = PBXHelper.uses_swift?(target)
      end

      def defines_module?
        return @defines_module if defined?(@defines_module)
        return @defines_module = true if build_as_framework?

        @defines_module = PBXHelper.defines_module?(target)
      end

      def context
        TargetContext.new(build_root,
                          temp_dir,
                          hmap_root,
                          temp_name,
                          build_dir,
                          product_name,
                          full_product_name,
                          defines_module?,
                          build_as_framework_swift?)
      end
    end
  end
end
