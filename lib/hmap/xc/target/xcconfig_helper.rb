# frozen_string_literal: true

module HMap
  # A collection of xcodeproj Helper functions used throughout hmap.
  class XcodeprojHelper
    HMAP_XCKEY_START = 'HMAP_'
    SAVE_XCKEY_START = 'SAVE_'
    private_constant :HMAP_XCKEY_START, :SAVE_XCKEY_START

    attr_reader :xcconfig_path

    def initialize(path)
      xc = Pathname(path)
      @xcconfig_path = xc
      @xcconfig = Xcodeproj::Config.new(xc)
    end

    def add_build_settings_and_save(settings, use_origin: true)
      add_build_settings(settings, use_origin)
      build_settings = [Constants::HEADER_SEARCH_PATHS, Constants::USER_HEADER_SEARCH_PATHS]
      if use_origin
        remove_build_settings(settings)
      else
        save_build_settings(settings)
      end
      save_as
    end

    def add_build_settings(settings, use_origin)
      settings.each do |key, value|
        add_build_setting(key.to_s, value, use_origin)
      end
    end

    def add_build_setting(key, value, use_origin)
      return if value.nil?

      if key.start_with?(HMAP_XCKEY_START)
        @xcconfig.attributes[key] = value
      else
        save_origin = save_build_setting(key)
        e_value = value
        e_value = "#{e_value} ${#{save_xckey(key)}}" if use_origin && !save_origin.nil?
        @xcconfig.attributes[hmap_xckey(key)] = e_value
        @xcconfig.attributes[key] = "${#{hmap_xckey(key)}}"
      end
    end

    def save_build_settings(settings)
      settings ||= []
      settings.each { |key| save_build_setting(key) }
    end

    def save_build_setting(key)
      origin = @xcconfig.attributes[key]
      if origin.nil? || !origin.include?(hmap_xckey(key))
        @xcconfig.attributes[save_xckey(key)] = origin unless origin.nil?
        @xcconfig.attributes.delete(key)
      end
      @xcconfig.attributes[save_xckey(key)]
    end

    def remove_build_settings_and_save

      hmap_ks = @xcconfig.attributes.keys.each_with_object([]) do |key, sum|
        sum << key[HMAP_XCKEY_START.length..-1] if key.start_with?(HMAP_XCKEY_START)
        sum << key[SAVE_XCKEY_START.length..-1] if key.start_with?(SAVE_XCKEY_START)
      end.compact
      remove_build_settings(hmap_ks)
      save_as
    end

    def remove_build_settings(settings)
      settings ||= []
      settings.each { |setting| remove_build_setting(setting) }
    end

    def remove_build_setting(setting)
      save_origin = @xcconfig.attributes[save_xckey(setting)]
      origin = @xcconfig.attributes[setting]
      if save_origin.nil? && !origin.nil? && origin.include?(hmap_xckey(setting))
        @xcconfig.attributes.delete(setting)
      end
      @xcconfig.attributes[setting] = save_origin unless save_origin.nil?
      @xcconfig.attributes.delete(hmap_xckey(setting))
      @xcconfig.attributes.delete(save_xckey(setting))
    end

    def save_as(path = nil)
      path = xcconfig_path if path.nil?
      @xcconfig.save_as(path)
    end

    private

    def build_setting?(key)
      !@xcconfig.attributes[key].nil?
    end


    def hmap_xckey(key)
      "#{HMAP_XCKEY_START}#{key}"
    end

    def save_xckey(key)
      "#{SAVE_XCKEY_START}#{key}"
    end
  end
end
