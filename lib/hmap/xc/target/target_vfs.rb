# frozen_string_literal: true

require 'yaml_vfs'

module HMap
  class TargetVFSEntry
    attr_reader :real_path, :virtual_path

    def initialize(build_dir, file)
      @real_path = file
      @virtual_path = File.join(build_dir, File.basename(file))
    end
  end

  class TargetPlatformVFS
    def initialize(platform, setting)
      @platform = platform
      @setting = setting
    end

    def product_name
      File.basename(build_dir, '.*')
    end

    def build_dir
      @setting.build_path(@platform)
    end

    def temp_dir
      @setting.temp_path(@platform)
    end

    def defines_modules?
      @setting.defines_modules?
    end

    def module_path
      File.join(temp_dir, 'module.modulemap') if defines_modules?
    end

    def private_module_path
      File.join(temp_dir, 'module.private.modulemap') if defines_modules?
    end

    def swift_header_path
      File.join(build_dir, 'Headers', "#{product_name}-Swift.h") if @setting.build_as_framework_swift?
    end

    def public_headers_dir
      File.join(build_dir, 'Headers')
    end

    def private_headers_dir
      File.join(build_dir, 'PrivateHeaders')
    end

    def module_dir
      File.join(build_dir, 'Modules')
    end
  end


  # A collection of Each TargetVFSEntry
  class TargetVFS
    def initialize(public_headers, private_headers, platforms, setting)
      @setting = setting
      @platforms = platforms
      @public_headers = public_headers
      @private_headers = private_headers
    end

    def add_headers_modules(config)
      r_public_paths = []
      r_public_paths += @public_headers
      s_h = config.swift_header_path
      r_public_paths << s_h unless s_h.nil?
      r_private_paths = []
      r_private_paths += @private_headers
      headers = []
      headers += add_files(r_public_paths, config.public_headers_dir)
      headers += add_files(r_private_paths, config.private_headers_dir)
      modules_real_paths = []
      if config.defines_modules?
        modules_real_paths << config.module_path
        modules_real_paths << config.private_module_path unless r_private_paths.empty?
      end
      headers += add_files(modules_real_paths, config.module_dir) || []
      headers
    end

    def add_files(files, virtual_dir)
      return if files.nil?

      files.map { |file| TargetVFSEntry.new(virtual_dir, file) }
    end

    def vfs_entrys
      Hash[@platforms.map do |platform|
        config = TargetPlatformVFS.new(platform, @setting)
        [platform.to_s, add_headers_modules(config)]
      end]
    end
  end

  class TargetVFSWriter
    attr_reader :entrys

    def initialize(entrys)
      @entrys = entrys
    end

    def write!(path)
      es = @entrys.map do |entry|
        VFS::FileCollectorEntry.new(entry.real_path, entry.virtual_path)
      end.uniq
      fc = VFS::FileCollector.new(es)
      pa = Pathname.new(path)
      pa.dirname.mkpath unless pa.exist?
      fc.write_mapping(pa)
    end
  end
end
