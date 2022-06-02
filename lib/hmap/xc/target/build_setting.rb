# frozen_string_literal: true

require 'hmap/xc/target/target_vfs'

module HMap
  class Platform
    attr_reader :configuration, :platform

    def self.new_from_platforms(configuration, platforms)
      Utils.effective_platforms_names(platforms).map { |pl| new(configuration, pl) }
    end

    def initialize(configuration, platform)
      @configuration = configuration
      @platform = platform
    end

    def to_s
      "#{configuration}-#{platform}"
    end
  end
end

module HMap
  class BuildSettings
    attr_reader :type, :platform

    def self.new_from_platforms(type, platforms, context)
      platforms.map { |platform| new(type, platform.to_s, context) }
    end

    def initialize(type, platform, context)
      @type = type
      @platform = platform.to_s || ''
      @context = context
    end

    def write_or_symlink(path, data, need_platform)
      return if data.nil? && path.nil?

      if data.nil?
        dir = platform if type == :all_product_headers
        path = Constants.instance.full_hmap_filepath(type, path, dir)
        symlink_to(path, need_platform)
      else
        write(data, need_platform)
      end
    end

    private

    def file_name
      return @file_name if defined? @file_name

      product_name = @context.product_name if @context.respond_to? :product_name
      @file_name = Constants.instance.full_hmap_filename(type)
    end

    def hmap_filepath(need_platform)
      platform = ''
      platform = @platform if need_platform
      hmap_root = File.join(@context.hmap_root, platform, @context.temp_name)
      File.join(hmap_root, file_name)
    end

    def symlink_to(path, need_platform)
      Utils.file_symlink_to(path, Pathname.new(hmap_filepath(need_platform)))
    end

    def write(data, need_platform)
      path = Constants.instance.full_hmap_filepath(type, hmap_filepath(need_platform))
      if type == :all_product_headers
        da = data[platform] || []
        TargetVFSWriter.new(da).write!(path)
      else
        HMapSaver.new_from_buckets(data).write_to(path)
      end
    end
  end

  class BuildSettingsWriter
    attr_reader :platforms

    # Initialize a new instance
    #
    # @param  [Array<HMap::Platform>] platforms
    #         the platforms to lint.
    #
    # @param  [HMap::Context] context
    #         the Project or target information.
    #
    def initialize(platforms, context)
      @platforms = platforms
      @context = context
    end

    def write_or_symlink(path, data, platforms = [])
      build_settings.each do |setting|
        type_data = data[setting.type] unless data.nil?
        next if type_data.nil? && path.nil?

        need_platform = platforms.include?(setting.type)
        setting.write_or_symlink(path, type_data, need_platform)
      end
    end

    private

    def build_settings
      return @build_settings if defined? @build_settings

      @build_settings = Constants::HMAP_FILE_TYPE.flat_map do |type|
        if @platforms.empty?
          BuildSettings.new(type, nil, @context)
        else
          BuildSettings.new_from_platforms(type, @platforms, @context)
        end
      end
    end
  end
end
