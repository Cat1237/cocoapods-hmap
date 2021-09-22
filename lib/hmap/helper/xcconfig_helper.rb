# frozen_string_literal: true

module HMap
  # A collection of xcodeproj Helper functions used throughout hmap.
  class XcodeprojHelper
    require 'xcodeproj'

    attr_reader :xcconfig_path, :build_setting_key

    def initialize(xcconfig)
      @xcconfig_path = xcconfig
      @xcconfig = Xcodeproj::Config.new(xcconfig_path)
    end

    def change_xcconfig_other_c_flags_and_save(values, use_headermap: false, save_origin: false)
      ocf = values[BuildSettingConstants::OTHER_CFLAGS]
      ocppf = values[BuildSettingConstants::OTHER_CPLUSPLUSFLAGS]
      change_xcconfig_build_setting(BuildSettingConstants::OTHER_CFLAGS, ocf, true) unless ocf.nil?
      cplusplus = has_build_setting(BuildSettingConstants::OTHER_CPLUSPLUSFLAGS)
      if cplusplus && !ocppf.nil?
        change_xcconfig_build_setting(BuildSettingConstants::OTHER_CPLUSPLUSFLAGS, ocppf, true)
      end
      change_xcconfig_build_setting(BuildSettingConstants::USE_HEADERMAP, 'NO', false) unless use_headermap
      build_settings = [BuildSettingConstants::HEAD_SEARCH_PATHS, BuildSettingConstants::USER_HEADER_SEARCH_PATHS]
      if save_origin
        clean_hmap_build_settings_to_xcconfig(build_settings)
      else
        save_build_setting_to_xcconfigs(build_settings)
      end
      save_to_path
    end

    def change_xcconfig_build_settings(settings, save_origin)
      settings.each do |key, value|
        change_xcconfig_build_setting(key.to_s, value, save_origin)
      end
    end

    def change_xcconfig_build_setting(build_setting_key, setting, save_origin)
      save_origin_build_setting = save_build_setting_to_xcconfig(build_setting_key)
      value = setting
      value = "#{value} ${#{save_key(build_setting_key)}}" if save_origin && !save_origin_build_setting.nil?
      @xcconfig.attributes[hmap_key(build_setting_key)] = value
      @xcconfig.attributes[build_setting_key] = "${#{hmap_key(build_setting_key)}}"
      yield(@xcconfig) if block_given?
    end

    def save_build_settings_to_xcconfig(build_settings)
      build_settings ||= []
      build_settings.each { |key| save_build_setting_to_xcconfig(key) }
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

    def clean_hmap_build_settings_to_xcconfig(build_settings)
      build_settings ||= []
      build_settings.each { |build_setting| clean_hmap_build_setting_to_xcconfig(build_setting) }
    end

    def clean_hmap_build_setting_to_xcconfig(build_setting)
      save_origin_build_setting = @xcconfig.attributes[save_key(build_setting)]
      @xcconfig.attributes[build_setting] = save_origin_build_setting unless save_origin_build_setting.nil?
      @xcconfig.attributes.delete(hmap_key(build_setting))
      @xcconfig.attributes.delete(save_key(build_setting))
    end

    def save_to_path(path = nil)
      path = xcconfig_path if path.nil?
      @xcconfig.save_as(path)
    end

    private

    def has_build_setting(key)
      !@xcconfig.attributes[key].nil?
    end

    def hmap_key(key)
      "HMAP_PODS_#{key}"
    end

    def save_key(key)
      "SAVE_#{key}"
    end
  end
end
