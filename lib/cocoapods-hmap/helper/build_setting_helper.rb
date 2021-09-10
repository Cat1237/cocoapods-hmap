module HMap
    # A collection of build setting functions used throughout cocoapods-hmap.
    module BuildSettingHelper
      def self.clean_hmap(clean_hmap, *targets)
        return clean_hmap unless clean_hmap
  
        FileUtils.rm_rf(Helper::Pods.hmap_files_dir)
        targets.each { |target| clean_other_c_flags_build_setting(target) }
        clean_hmap
      end
  
      def self.target_xcconfig_path(targets)
        targets.each do |target|
          raise ClassIncludedError.new(target.class, Pod::Target) unless target.is_a?(Pod::Target)
  
          config_h = Pod::Target.instance_method(:build_settings).bind(target).call
          config_h.each_key do |configuration_name|
            xcconfig = target.xcconfig_path(configuration_name)
            yield(xcconfig, target) if block_given?
          end
        end
      end
  
      def self.clean_other_c_flags_build_setting(targets)
        target_xcconfig_path(targets) do |xc, _|
          c = HMap::XcodeprojHelper.new(xc)
          c.clean_hmap_xcconfig_other_c_flags_and_save
          puts "\t -xcconfig path: #{xc} clean finish."
        end
      end
  
      def self.change_other_c_flags_xcconfig_build_settings(hmap_h, targets, use_headermap: false, save_origin: true)
        target_xcconfig_path(targets) do |xc, target|
          c = HMap::XcodeprojHelper.new(xc)
          c.change_xcconfig_other_c_flags_and_save(hmap_h, target.build_as_framework?, use_headermap: use_headermap,
                                                                                       save_origin: save_origin)
        end
      end
    end
  end