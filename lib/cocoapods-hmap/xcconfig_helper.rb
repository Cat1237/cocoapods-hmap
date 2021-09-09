# frozen_string_literal: true

module HMap
  # A collection of Helper functions used throughout cocoapods-hmap.
  class XcodeprojHelper
    require 'xcodeproj'
    OTHER_CFLAGS = 'OTHER_CFLAGS'
    HEAD_SEARCH_PATHS = 'HEADER_SEARCH_PATHS'
    # A collection of Pods Helper functions used throughout cocoapods-hmap.
    attr_reader :xcconfig_path, :build_setting_key

    def initialize(xcconfig)
      @xcconfig_path = xcconfig
      @xcconfig = Xcodeproj::Config.new(xcconfig_path)
    end

    def change_xcconfig_other_c_flags_and_save(values, build_as_framework, use_headermap: false, save_origin: true)
      setting = values.flat_map do |config|
        ['$(inherited)', "-I\"#{Helper::Pods.pods_hmap_files_dir}/#{config}.hmap\"",
         "-iquote \"#{Helper::Pods.pods_hmap_files_dir}/#{config}-iquote.hmap\""]
      end
      if build_as_framework
        setting << "-ivfsoverlay \"#{Helper::Pods.pods_hmap_files_dir}/vfs/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)/all-product-headers.yaml\""
      end
      change_xcconfig_build_setting(OTHER_CFLAGS, setting.join(' '), save_origin) do |xcconfig|
        xcconfig.attributes['USE_HEADERMAP'] = 'NO' unless use_headermap
        save_build_setting_to_xcconfig(HMap::XcodeprojHelper::HEAD_SEARCH_PATHS)
      end
      save_to_path
    end

    def change_xcconfig_build_setting(build_setting_key, setting, save_origin)
      origin_build_setting = @xcconfig.attributes[build_setting_key]
      save_origin_build_setting = save_build_setting_to_xcconfig(build_setting_key)
      hmap_build_setting = @xcconfig.attributes[hmap_key(build_setting_key)]
      value = setting
      value = "#{value} ${#{save_key(build_setting_key)}}" if save_origin && !save_origin_build_setting.nil?
      @xcconfig.attributes[hmap_key(build_setting_key)] = value
      @xcconfig.attributes[build_setting_key] = "${#{hmap_key(build_setting_key)}}"
      yield(@xcconfig) if block_given?
    end

    def save_build_setting_to_xcconfig(key)
      origin_build_setting = @xcconfig.attributes[key]
      if origin_build_setting.nil? || !origin_build_setting.include?(hmap_key(key))
        @xcconfig.attributes[save_key(key)] = origin_build_setting unless origin_build_setting.nil?
        @xcconfig.attributes.delete(key)
      end
      @xcconfig.attributes[save_key(key)]
    end

    def clean_hmap_xcconfig_other_c_flags_and_save
      clean_hmap_build_setting_to_xcconfig(OTHER_CFLAGS)
      clean_hmap_build_setting_to_xcconfig(HEAD_SEARCH_PATHS)
      @xcconfig.attributes['USE_HEADERMAP'] = 'YES'
      save_to_path
    end

    def clean_hmap_build_setting_to_xcconfig(build_setting)
      save_origin_build_setting = @xcconfig.attributes[save_key(build_setting)]
      origin_build_setting = @xcconfig.attributes[build_setting]
      @xcconfig.attributes[build_setting] = save_origin_build_setting unless save_origin_build_setting.nil?
      @xcconfig.attributes.delete(hmap_key(build_setting))
      @xcconfig.attributes.delete(save_key(build_setting))
    end

    def save_to_path(path = nil)
      path = xcconfig_path if path.nil?
      @xcconfig.save_as(path)
    end

    private

    def hmap_key(key)
      "HMAP_PODS_#{key}"
    end

    def save_key(key)
      "SAVE_#{key}"
    end
  end
end
