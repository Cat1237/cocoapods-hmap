module HMap
  # This class holds the data for a Xcode build settings file (xcconfig) and
  # provides support for serialization.
  #
  class XCConfig
    require 'set'

    KEY_VALUE_PATTERN = /
      (
        [^=\[]+     # Any char, but not an assignment operator
                    # or subscript (non-greedy)
        (?:         # One or multiple conditional subscripts
          \[
          [^\]]*    # The subscript key
          (?:
            =       # The subscript comparison operator
            [^\]]*  # The subscript value
          )?
          \]
        )*
      )
      \s*           # Whitespaces after the key (needed because subscripts
                    # always end with ']')
      =             # The assignment operator
      (.*)          # The value
    /x
    private_constant :KEY_VALUE_PATTERN

    INHERITED = %w($(inherited) ${inherited}).freeze
    private_constant :INHERITED

    INHERITED_REGEXP = Regexp.union(INHERITED)
    private_constant :INHERITED_REGEXP

    # @return [Hash{String => String}] The attributes of the settings file
    #         excluding frameworks, weak_framework and libraries.
    #
    attr_accessor :attributes

    # @return [Array] The list of the configuration files included by this
    #         configuration file (`#include "SomeConfig"`).
    #
    attr_accessor :includes_paths

    # @return [Hash{Symbol => Set<String>}] The other linker flags by key.
    #         Xcodeproj handles them in a dedicated way to prevent duplication
    #         of the libraries and of the frameworks.
    #
    def initialize(xcconfig_hash_or_file = {})
      @attributes = {}
      @includes = []
      @include_attributes = {}
      merge!(extract_hash(xcconfig_hash_or_file))
      @includes_paths = @includes.map { |i| File.expand_path(i, @filepath.dirname) }
    end

    def inspect
      to_hash.inspect
    end

    def ==(other)
      other.attributes == attributes && other.includes_paths = @includes_paths
    end

    # @!group Serialization
    #-------------------------------------------------------------------------#

    # Sorts the internal data by setting name and serializes it in the xcconfig
    # format.
    #
    # @example
    #
    #   config = Config.new('PODS_ROOT' => '"$(SRCROOT)/Pods"', 'OTHER_LDFLAGS' => '-lxml2')
    #   config.to_s # => "OTHER_LDFLAGS = -lxml2\nPODS_ROOT = \"$(SRCROOT)/Pods\""
    #
    # @return [String] The serialized internal data.
    #
    def to_s(prefix = nil)
      include_lines = @includes.map { |path| "#include \"#{normalized_xcconfig_path(path)}\"" }
      settings = to_hash(prefix).sort_by(&:first).map { |k, v| "#{k} = #{v}".strip }
      (include_lines + settings).join("\n") << "\n"
    end

    # Writes the serialized representation of the internal data to the given
    # path.
    #
    # @param  [Pathname] pathname
    #         The file where the data should be written to.
    #
    # @return [void]
    #
    def save_as(pathname, prefix = nil)
      return if File.exist?(pathname) && (XCConfig.new(pathname) == self)

      pathname.open('w') { |file| file << to_s(prefix) }
    end

    # The hash representation of the xcconfig. The hash includes the
    # frameworks, the weak frameworks, the libraries and the simple other
    # linker flags in the `Other Linker Flags` (`OTHER_LDFLAGS`).
    #
    # @note   All the values are sorted to have a consistent output in Ruby
    #         1.8.7.
    #
    # @return [Hash] The hash representation
    #
    def to_hash(prefix = nil)
      result = attributes.dup
      result.reject! { |_, v| INHERITED.any? { |i| i == v.to_s.strip } }
      if prefix
        Hash[result.map { |k, v| [prefix + k, v] }]
      else
        result
      end
    end

    alias to_h to_hash

    # @!group Merging
    #-------------------------------------------------------------------------#

    # Merges the given xcconfig representation in the receiver.
    # @note   If a key in the given hash already exists in the internal data
    #         then its value is appended.
    #
    # @param  [Hash, Config] config
    #         The xcconfig representation to merge.
    #
    # @todo   The logic to normalize an hash should be extracted and the
    #         initializer should not call this method.
    #
    # @return [void]
    #
    def merge!(xcconfig)
      if xcconfig.is_a? XCConfig
        merge_attributes!(xcconfig.attributes)
      else
        merge_attributes!(xcconfig.to_hash)
      end
    end
    alias << merge!

    # Creates a new #{Config} with the data of the receiver merged with the
    # given xcconfig representation.
    #
    # @param  [Hash, Config] config
    #         The xcconfig representation to merge.
    #
    # @return [Config] the new xcconfig.
    #
    def merge(config)
      dup.tap { |x| x.merge!(config) }
    end

    # @return [Config] A copy of the receiver.
    #
    def dup
      HMap::XCConfig.new(to_hash.dup)
    end

    #-------------------------------------------------------------------------#

    private

    # @!group Private Helpers

    # Returns a hash from the given argument reading it from disk if necessary.
    #
    # @param  [String, Pathname, Hash] argument
    #         The source from where the hash should be extracted.
    #
    # @return [Hash]
    #
    def extract_hash(argument)
      return argument if argument.is_a?(Hash)

      if argument.respond_to? :read
        @filepath = Pathname.new(argument.to_path)
        hash_from_file_content(argument.read)
      elsif File.readable?(argument.to_s)
        @filepath = Pathname.new(argument.to_s)
        hash_from_file_content(File.read(argument))
      else
        argument
      end
    end

    # Returns a hash from the string representation of an Xcconfig file.
    #
    # @param  [String] string
    #         The string representation of an xcconfig file.
    #
    # @return [Hash] the hash containing the xcconfig data.
    #
    def hash_from_file_content(string)
      hash = {}
      string.split("\n").each do |line|
        uncommented_line = strip_comment(line)
        e = extract_include(uncommented_line)
        if e.nil?
          key, value = extract_key_value(uncommented_line)
          next unless key
          value.gsub!(INHERITED_REGEXP) { |m| hash.fetch(key, m) }
          hash[key] = value
        else
          @includes.push normalized_xcconfig_path(e)
        end
      end
      hash
    end

    # Merges the given attributes hash while ensuring values are not duplicated.
    #
    # @param  [Hash] attributes
    #         The attributes hash to merge into @attributes.
    #
    # @return [void]
    #
    def merge_attributes!(attributes)
      @attributes.merge!(attributes) do |_, v1, v2|
        v1 = v1.strip
        v2 = v2.strip
        v1_split = v1.shellsplit
        v2_split = v2.shellsplit
        if (v2_split - v1_split).empty? || v1_split.first(v2_split.size) == v2_split
          v1
        elsif v2_split.first(v1_split.size) == v1_split
          v2
        else
          "#{v1} #{v2}"
        end
      end
    end

    # Strips the comments from a line of an xcconfig string.
    #
    # @param  [String] line
    #         the line to process.
    #
    # @return [String] the uncommented line.
    #
    def strip_comment(line)
      line.partition('//').first
    end

    # Returns the file included by a line of an xcconfig string if present.
    #
    # @param  [String] line
    #         the line to process.
    #
    # @return [String] the included file.
    # @return [Nil] if no include was found in the line.
    #
    def extract_include(line)
      regexp = /#include\s*"(.+)"/
      match = line.match(regexp)
      match[1] if match
    end

    # Returns the key and the value described by the given line of an xcconfig.
    #
    # @param  [String] line
    #         the line to process.
    #
    # @return [Array] A tuple where the first entry is the key and the second
    #         entry is the value.
    #
    def extract_key_value(line)
      match = line.match(KEY_VALUE_PATTERN)
      if match
        key = match[1]
        value = match[2]
        [key.strip, value.strip]
      else
        []
      end
    end

    # Normalizes the given path to an xcconfing file to be used in includes,
    # appending the extension if necessary.
    #
    # @param  [String] path
    #         The path of the file which will be included in the xcconfig.
    #
    # @return [String] The normalized path.
    #
    def normalized_xcconfig_path(path)
      if File.extname(path) == '.xcconfig'
        path
      else
        "#{path}.xcconfig"
      end
    end
  end
end
