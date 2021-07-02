# frozen_string_literal: true

module HMap
  # A collection of utility functions used throughout cocoapods-hmap.
  module Utils
    def self.index_of_range(num, range)
      num &= range - 1
      num
    end

    def self.power_of_two?(num)
      num != 0 && (num & (num - 1)).zero?
    end

    def self.next_power_of_two(num)
      num |= (num >> 1)
      num |= (num >> 2)
      num |= (num >> 4)
      num |= (num >> 8)
      num |= (num >> 16)
      num |= (num >> 32)
      num + 1
    end

    def self.hash_set_value(hash, *args)
      args.each do |arg|
        hash.merge(arg)
      end
      hash
    end

    def self.specialize_format(format, swapped)
      modifier = swapped ? '<' : '>'
      format.tr('=', modifier)
    end

    def self.string_downcase_hash(str)
      str.downcase.bytes.inject(0) do |sum, value|
        sum += value * 13
        sum
      end
    end

    def self.update_changed_file(path, contents)
      if path.exist?
        content_stream = StringIO.new(contents)
        identical = File.open(path, 'rb') { |f| FileUtils.compare_stream(f, content_stream) }
        return if identical
      end
      path.dirname.mkpath
      File.open(path, 'w') { |f| f.write(contents) }
    end

    def self.swapped_magic?(magic, version)
      magic.eql?(HEADER_CONST[:HMAP_SWAPPED_MAGIC]) && version.eql?(HEADER_CONST[:HMAP_SWAPPED_VERSION])
    end

    def self.magic?(magic)
      magic.eql?(HEADER_CONST[:HMAP_SWAPPED_MAGIC]) || magic.eql?(HEADER_CONST[:HMAP_HEADER_MAGIC_NUMBER])
    end

    def self.safe_encode(string, target_encoding)
      string.encode(target_encoding)
    rescue Encoding::InvalidByteSequenceError
      string.force_encoding(target_encoding)
    rescue Encoding::UndefinedConversionError
      string.encode(target_encoding, fallback: lambda { |c|
        c.force_encoding(target_encoding)
      })
    end

    def self.clean_target_build_setting(targets, build_setting)
      target_xcconfig_path(targets) do |xc|
        clean_build_setting_to_xcconfig(xc, build_setting)
      end
    end

    def self.target_xcconfig_path(targets)
      targets.each do |target|
        raise ClassIncludedError.new(target.class, Pod::Target) unless target.is_a?(Pod::Target)

        config_h = Pod::Target.instance_method(:build_settings).bind(target).call
        config_h.each_key do |configuration_name|
          xcconfig = target.xcconfig_path(configuration_name)
          yield(xcconfig) if block_given?
        end
      end
    end

    def self.chang_xcconfig_header_search_path(xcconfig, hmap_h, use_headermap: true, save_origin: true)
      hmap_header_serach_paths = hmap_h.inject('') do |sum, hmap_n|
        hmap_pod_root_path = "${PODS_ROOT}/Headers/#{HMAP_DIR}/#{hmap_n}"
        sum + "\"#{hmap_pod_root_path}\" "
      end
      save_build_setting_to_xcconfig(xcconfig, hmap_header_serach_paths, HEAD_SEARCH_PATHS,
                                     save_origin: save_origin) do |xc|
        xc.attributes['USE_HEADERMAP'] = 'NO' unless use_headermap
      end
    end

    def self.save_build_setting_to_xcconfig(path, value, build_setting, save_origin: true)
      xc = Xcodeproj::Config.new(path)
      save_origin_build_setting = "SAVE_#{build_setting}"
      hmap_build_setting = "HMAP_PODS_#{build_setting}"
      origin_build_setting = xc.attributes[build_setting]
      unless !origin_build_setting.nil? && origin_build_setting.include?(hmap_build_setting)
        xc.attributes[save_origin_build_setting] =
          origin_build_setting
      end

      value = "#{value} ${#{save_origin_build_setting}}" if save_origin
      xc.attributes[hmap_build_setting] = value
      xc.attributes[build_setting] = "${#{hmap_build_setting}}"
      yield(xc) if block_given?
      xc.save_as(path)
    end

    def self.clean_build_setting_to_xcconfig(path, build_setting)
      xc = Xcodeproj::Config.new(path)
      save_origin_build_setting = "SAVE_#{build_setting}"
      hmap_build_setting = "HMAP_PODS_#{build_setting}"
      origin_build_setting = xc.attributes[save_origin_build_setting]
      puts "\t -xcconfig path: #{path}"
      if origin_build_setting.nil?
        puts "\t   don't have #{save_origin_build_setting} in xcconfig file.".red
        return
      end
      xc.attributes[build_setting] = origin_build_setting
      xc.attributes.delete(save_origin_build_setting)
      xc.attributes.delete(hmap_build_setting)
      xc.attributes['USE_HEADERMAP'] = 'YES'
      xc.save_as(path)
      puts "\t   clean finish."
    end

    def self.pod_analyze(config)
      podfile = Pod::Podfile.from_file(config.podfile_path)
      lockfile = Pod::Lockfile.from_file(config.lockfile_path)
      Pod::Installer::Analyzer.new(config.sandbox, podfile, lockfile).analyze
    end
  end
end
