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

    def self.save_build_setting_to_xcconfig(path, value, build_setting, save_origin: true)
      xc = Xcodeproj::Config.new(path)
      origin_build_setting = xc.attributes[build_setting]
      return if !origin_build_setting.nil? && origin_build_setting.strip.include?(value.strip)

      xc.attributes[build_setting] = value
      xc.attributes[build_setting] = "#{value} #{origin_build_setting}" if save_origin
      xc.save_as(path)
    end

    def self.pod_analyze(config)
      podfile = Pod::Podfile.from_file(config.podfile_path)
      lockfile = Pod::Lockfile.from_file(config.lockfile_path)
      Pod::Installer::Analyzer.new(config.sandbox, podfile, lockfile).analyze
    end
  end
end
