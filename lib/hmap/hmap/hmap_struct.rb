# frozen_string_literal: true

module HMap
  HEADER_CONST = {
    HMAP_HEADER_MAGIC_NUMBER: 0x686d6170,
    HMAP_HEADER_VERSION: 0x0001,
    HMAP_EMPTY_BUCKT_KEY: 0,
    HMAP_SWAPPED_MAGIC: 0x70616d68,
    HMAP_SWAPPED_VERSION: 0x0100
  }.freeze

  EMPTY_HMAP = "pamh\u0001\u0000\u0000\u0000x\u0000\u0000\u0000\u0000\u0000\u0000\u0000\b\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000"
  EMPTY_BUCKET = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
  private_constant :EMPTY_HMAP
  # A general purpose pseudo-structure.
  # @abstract
  class HMapStructure
    # The String#unpack format of the data structure.
    # @return [String] the unpacking format
    # @api private
    FORMAT = ''

    # The size of the data structure, in bytes.
    # @return [Integer] the size, in bytes
    # @api private
    SIZEOF = 0

    SWAPPED = true

    # @return [Integer] the size, in bytes, of the represented structure.
    def self.bytesize
      self::SIZEOF
    end

    def self.format
      self::FORMAT
    end

    def self.swapped?
      self::SWAPPED
    end

    # @param endianness [Symbol] either `:big` or `:little`
    # @param bin [String] the string to be unpacked into the new structure
    # @return [HMap::HMapStructure] the resulting structure
    # @api private
    def self.new_from_bin(swapped, bin)
      format = Utils.specialize_format(self::FORMAT, swapped)
      new(*bin.unpack(format))
    end

    def serialize
      [].pack(format)
    end

    # @return [Hash] a hash representation of this {HMapStructure}.
    def to_h
      {
        'structure' => {
          'format' => self.class::FORMAT,
          'bytesize' => self.class.bytesize
        }
      }
    end
  end

  # HMapHeader structure.
  # @see https://clang.llvm.org/doxygen/structclang_1_1HMapHeader.html
  # @abstract
  class HMapHeader < HMapStructure
    # @return [HMap::HMapHeader, nil] the raw view associated with the load command,
    #  or nil if the HMapHeader was created via {create}.
    attr_reader :num_entries, :magic, :version, :reserved, :strings_offset, :num_buckets, :max_value_length

    FORMAT = 'L=1S=2L=4'
    # @see HMapStructure::SIZEOF
    # @api private
    SIZEOF = 24

    # @api private
    def initialize(magic, version, reserved, strings_offset, num_entries, num_buckets, max_value_length)
      @magic = magic
      @version = version
      @reserved = reserved
      @strings_offset = strings_offset
      @num_entries = num_entries
      @num_buckets = num_buckets
      @max_value_length = max_value_length
      super()
    end

    # @return [String] the serialized fields of the mafile
    def serialize
      format = Utils.specialize_format(FORMAT, SWAPPED)
      [magic, version, reserved, strings_offset, num_entries, num_buckets, max_value_length].pack(format)
    end

    def description
      <<-DESC
        Hash bucket count: #{@num_buckets}
        String table entry count: #{@num_entries}
        Max value length: #{@max_value_length}
      DESC
    end

    def to_h
      {
        'magic' => magic,
        'version' => version,
        'reserved' => reserved,
        'strings_offset' => strings_offset,
        'num_entries' => num_entries,
        'num_buckets' => num_buckets,
        'max_value_length' => max_value_length
      }.merge super
    end
  end

  # HMapBucket structure.
  # @see https://clang.llvm.org/doxygen/structclang_1_1HMapHeader.html
  # @abstract
  class HMapBucket < HMapStructure
    attr_accessor :key, :perfix, :suffix

    SIZEOF = 12
    FORMAT = 'L=3'

    def initialize(key, perfix, suffix)
      @key = key
      @perfix = perfix
      @suffix = suffix
      super()
    end

    # @return [String] the serialized fields of the mafile
    def serialize
      format = Utils.specialize_format(FORMAT, SWAPPED)
      [key, perfix, suffix].pack(format)
    end

    def to_a
      [key, perfix, suffix]
    end

    def to_h
      {
        'key' => key,
        'perfix' => perfix,
        'suffix' => suffix
      }.merge super
    end
  end

  # HMap blobs.
  class HMapData
    def initialize(strings, buckets, entries)
      super()
      return if strings.nil? || buckets.empty?

      @buckets = buckets
      @strings = strings
      @header = populate_hmap_header(buckets.count, entries)
    end

    # @return [String] the serialized fields of the mafile
    def serialize
      return EMPTY_HMAP if @strings.nil?

      @header.serialize + @buckets.join + @strings
    end

    private

    def populate_hmap_header(num_buckets, entries)
      strings_offset = HMapHeader.bytesize + HMapBucket.bytesize * num_buckets
      HMapHeader.new(HEADER_CONST[:HMAP_HEADER_MAGIC_NUMBER],
                     HEADER_CONST[:HMAP_HEADER_VERSION], 0, strings_offset, entries, num_buckets, 0)
    end
  end
end
