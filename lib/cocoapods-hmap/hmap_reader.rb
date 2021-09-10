# frozen_string_literal: true

module HMap
  # hmap bucket
  class HMapBucketStr
    attr_reader :key, :perfix, :suffix

    def initialize(key, perfix, suffix)
      @key = key
      @perfix = perfix
      @suffix = suffix
    end

    def description
      <<-DESC
        Key #{@key} -> Prefix #{@perfix}, Suffix #{@suffix}
      DESC
    end
  end
  # hmap file reader
  class MapFileReader
    # @return [String, nil] the filename loaded from, or nil if loaded from a binary
    #  string
    attr_reader :filename
    # # @return [Hash] any parser options that the instance was created with
    # attr_reader :options

    # @return true/false the swapped of the mapfile
    attr_reader :swapped

    # @return [HMap::HMapHeader]
    attr_reader :header

    # @return [Hash<HMap::HMapBucket => HMap::HMapBucketStr>] an array of the file's bucktes
    # @note bucktes are provided in order of ascending offset.
    attr_reader :bucktes

    def initialize(path)
      raise ArgumentError, "#{path}: no such file" unless File.file?(path)

      @filename = path
      @raw_data = File.open(@filename, 'rb', &:read)
      populate_fields
      puts description
    end

    # Populate the instance's fields with the raw HMap data.
    # @return [void]
    # @note This method is public, but should (almost) never need to be called.
    def populate_fields
      @header = populate_hmap_header
      string_t = @raw_data[header.strings_offset..-1]
      @bucktes = populate_buckets do |bucket|
        bucket_s = bucket.to_a.map do |key|
          string_t[key..-1].match(/[^\0]+/)[0]
        end
        HMapBucketStr.new(*bucket_s)
      end
    end

    private

    # The file's HMapheader structure.
    # @return [HMap::HMapHeader]
    # @raise [TruncatedFileError] if the file is too small to have a valid header
    # @api private
    def populate_hmap_header
      raise TruncatedFileError if @raw_data.size < HMapHeader.bytesize + 8 * HMapBucket.bytesize

      populate_and_check_magic
      HMapHeader.new_from_bin(swapped, @raw_data[0, HMapHeader.bytesize])
    end

    # Read just the file's magic number and check its validity.
    # @return [Integer] the magic
    # @raise [MagicError] if the magic is not valid HMap magic
    # @api private
    def populate_and_check_magic
      magic = @raw_data[0..3].unpack1('N')
      raise MagicError, magic unless Utils.magic?(magic)

      version = @raw_data[4..5].unpack1('n')
      @swapped = Utils.swapped_magic?(magic, version)
    end

    # All buckets in the file.
    # @return [Array<HMap::HMapBucket>]  an array of buckets
    # @api private
    def populate_buckets
      bucket_offset = header.class.bytesize
      bucktes = []
      header.num_buckets.times do |i|
        bucket = HMapBucket.new_from_bin(swapped, @raw_data[bucket_offset, HMapBucket.bytesize])
        bucket_offset += HMapBucket.bytesize
        next if bucket.key == HEADER_CONST[:HMAP_EMPTY_BUCKT_KEY]

        bucktes[i] = { bucket => yield(bucket) }
      end
      bucktes
    end

    # description
    def description
      sum = "  Header map: #{filename}\n" + header.description
      bucktes.each_with_index do |buckte_h, index|
        sum += "\t- Bucket: #{index}" + Utils.safe_encode(buckte_h.values[0].description, 'UTF-8') unless buckte_h.nil?
        sum
      end
      sum
    end
  end
end
