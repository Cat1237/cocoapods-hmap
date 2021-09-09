# frozen_string_literal: false

require 'cocoapods'

module HMap
  # A collection of utility functions used throughout cocoapods-hmap.
  module Utils
    HEADER_EXTENSIONS = Pod::Sandbox::FileAccessor::HEADER_EXTENSIONS

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

    def self.clean_hmap(clean_hmap, *targets)
      return clean_hmap unless clean_hmap

      FileUtils.rm_rf(Helper::Pods.hmap_files_dir)
      targets.each do |tg|
        clean_target_build_setting(tg)
      end
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

    def self.clean_target_build_setting(targets, _build_setting = nil)
      target_xcconfig_path(targets) do |xc, _|
        c = HMap::XcodeprojHelper.new(xc)
        c.clean_hmap_xcconfig_other_c_flags_and_save
        puts "\t -xcconfig path: #{xc} clean finish."
      end
    end

    def self.change_target_xcconfig_build_settings(hmap_h, targets, use_headermap: false, save_origin: true)
      target_xcconfig_path(targets) do |xc, target|
        c = HMap::XcodeprojHelper.new(xc)
        c.change_xcconfig_other_c_flags_and_save(hmap_h, target.build_as_framework?, use_headermap: use_headermap,
                                                                                     save_origin: save_origin)
      end
    end
  end
end

# HEADER_SEARCH_PATHS = ${HMAP_PODS_HEADER_SEARCH_PATHS}
# HMAP_PODS_HEADER_SEARCH_PATHS = -iquote "${PODS_ROOT}/Headers/WCDB.swift.build/WCDBSwift-generated-files.hmap" -I"${PODS_ROOT}/Headers/WCDB.swift.build/WCDBSwift-own-target-headers.hmap" -I"${PODS_ROOT}/Headers/WCDB.swift.build/WCDBSwift-all-non-framework-target-headers.hmap" -iquote "${PODS_ROOT}/Headers/WCDB.swift.build/WCDBSwift-project-headers.hmap"
# HMAP_PODS_OTHER_CFLAGS = $(inherited) -ivfsoverlay ${PODS_ROOT}/Headers/HMap/vfs/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)/all-product-headers.yaml
