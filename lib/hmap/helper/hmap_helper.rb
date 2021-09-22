# frozen_string_literal: true

require 'Set'

module HMap
  # HMap file information
  class HMapHeaderEntry
    attr_reader :type, :headers

    def initialize(type)
      @type = type
      @headers = []
    end

    def add_header(header)
      headers << header
    end

    def file_name(name)
      name = 'hmap' if name.nil?
      [name, '-', type, '.hmap'].join
    end

    def build_setting_key
      case type
      when :i_headers, :iextra_headers
        yield('-I', :HEADER_SEARCH_PATHS) if block_given?
      when :iquote_headers, :extra_headers
        yield('-iquote', :USER_HEADER_SEARCH_PATHS) if block_given?
      else
        raise Informative, "Error: header type not expect#{type}"
      end
    end

    def build_setting(path, name)
      full_path = File.join(path, file_name(name))
      build_setting_key do |key|
        [key, "\"#{full_path}\""]
      end
    end

    def build_setting_xcconfig(path, name)
      full_path = File.join(path, file_name(name))
      build_setting_key do |_, xc|
        [xc, "\"#{full_path}\""]
      end
    end
  end

  # A collection of Each HMapHeaderEntry
  class HMapHeaders
    def initialize
      @public_headers = HMapHeaderEntry.new(:i_headers)
      @public_e_headers = HMapHeaderEntry.new(:iextra_headers)
      @private_headers = HMapHeaderEntry.new(:iquote_headers)
      @private_e_headers = HMapHeaderEntry.new(:extra_headers)
      @unqi_headers = Set.new
    end

    def headers
      public_headers + private_headers
    end

    def public_headers
      [@public_headers, @public_e_headers]
    end

    def private_headers
      [@private_headers, @private_e_headers]
    end

    def private_setting_for_reference(path, name)
      headers_build_settings_for_reference(private_headers, path, name)
    end

    def public_setting_for_reference(path, name)
      headers_build_settings_for_reference(public_headers, path, name)
    end

    def private_setting_for_options(path, name)
      headers_build_settings_for_options(private_headers, path, name, ' ').join(' ')
    end

    def public_setting_for_options(path, name)
      headers_build_settings_for_options(public_headers, path, name).join(' ')
    end

    def headers_build_settings_for_reference(headers, path, name)
      headers.each_with_object({}) do |header, setting|
        se = header.build_setting_xcconfig(path, name)
        setting.merge!(Hash[*se]) { |_, oldval, newval| [oldval, newval].join(' ') }
      end
    end

    def headers_build_settings_for_options(headers, path, name, key = '')
      headers.each_with_object([]) do |header, setting|
        setting << header.build_setting(path, name).join(key)
      end
    end

    def add_headers(type, headers, module_name, headers_sandbox)
      headers.each do |header|
        next unless @unqi_headers.add?(header)

        header_name = header.basename.to_s
        header_dir = "#{header.dirname}/"
        header_module_path = "#{module_name}/#{header_name}"
        header_module_name = "#{module_name}/"
        header_relative_path = header.relative_path_from(headers_sandbox).to_s
        header_last_dir_name = "#{header.dirname.basename}/#{header_name}"
        case type
        when :private_header_files, :public_header_files
          @public_headers.add_header([header_name, header_module_name, header_name]) if type == :public_header_files
          @public_e_headers.add_header([header_module_path, header_dir, header_name])
          @private_headers.add_header([header_name, header_module_name, header_name])
          unless header_relative_path == header_module_path || header_relative_path == header_name
            @private_e_headers.add_header([header_relative_path, header_dir, header_name])
          end
          unless header_last_dir_name == header_module_path
            @private_e_headers.add_header([header_last_dir_name, header_dir, header_name])
          end
        when :source_files
          @private_e_headers.add_header([header_name, header_dir, header_name])
          @private_e_headers.add_header([header_last_dir_name, header_dir, header_name])
          @private_e_headers.add_header([header_relative_path, header_dir, header_name])
        end
      end
    end
  end

  class HMapHelper
    attr_reader :i_headers, :iquote_headers, :directory, :framework_entrys, :headers

    def initialize(directory)
      puts "Current hmap files dir: #{directory}"
      @directory = Pathname(directory)
      @framework_entrys = []
      @headers = HMapHeaders.new
    end

    def write_hmapfile(name = nil)
      return if directory.nil?

      @headers.headers.each do |entry|
        path = directory.join(entry.file_name(name))
        hmap_write_headers_to_path(path, entry.headers)
      end
    end

    def i_headers_name(name)
      directory.join("#{name}.hmap")
    end

    def iquote_headers_name
      directory.join("#{name}-iquote.hmap")
    end

    def write_vfsfiles(name = '')
      return if framework_entrys.empty?

      vfs_directory = directory.join(name).join('vfs')
      puts "Current vfs files dir: #{vfs_directory}"
      Target::FrameworkVFS.new(framework_entrys).write(vfs_directory)
      puts 'vfs files write finish.'
    end

    def write_hmap_vfs_to_paths(hmap_name = nil, vfs_name = '')
      write_vfsfiles(vfs_name)
      write_hmapfile(hmap_name)
    end

    def add_framework_entry(configurations, platforms, name, framework_name, module_path, headers)
      entry = Target::FrameworkEntry.new_entrys_from_configurations_platforms(configurations, platforms, name,
                                                                              framework_name, module_path, headers)
      @framework_entrys += entry
    end

    def xcconfig_header_setting(is_framework, path = nil, name = nil)
      xcconfig_hmap_setting(is_framework, name, path)
    end

    def xcconfig_hmap_setting(is_framework, name = nil, path = nil)
      setting = {}
      i_s = @headers.public_setting_for_options(path, name)
      iquote = @headers.private_setting_for_options(path, name)
      setting[BuildSettingConstants::OTHER_CFLAGS] =
        setting[BuildSettingConstants::OTHER_CPLUSPLUSFLAGS] = [BuildSettingConstants::INGERITED, i_s].join(' ')
      if is_framework
        vfs_setting = "-ivfsoverlay' \"#{path}/vfs/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)/all-product-headers.yaml\""
        setting.merge!({ BuildSettingConstants::OTHER_CFLAGS => vfs_setting,
                         BuildSettingConstants::OTHER_CPLUSPLUSFLAGS => vfs_setting }) do |_, oldval, newval|
          [oldval, newval].join(' ')
        end
      end
      setting.merge!({ BuildSettingConstants::OTHER_CFLAGS => iquote,
                       BuildSettingConstants::OTHER_CPLUSPLUSFLAGS => iquote }) do |_, oldval, newval|
        [oldval, newval].join(' ')
      end
    end

    def header_mappings(headers, headers_sandbox, module_name, type)
      @headers.add_headers(type, headers, module_name, headers_sandbox)
    end

    private

    def hmap_write_headers_to_path(path, headers)
      return if headers.empty?

      print "\t - Save hmap file to path: "
      puts path.to_s.yellow
      HMapSaver.new_from_buckets(headers).write_to(path)
    end
  end
end
