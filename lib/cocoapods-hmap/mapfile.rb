# frozen_string_literal: true

module HMap
  # hmap file writer
  class MapFile
    # @return mapfile string_table
    attr_reader :string_table

    # @return [Array<HMap::HMapBucketStr>] an array of the file's bucktes
    # @note bucktes are provided in order of ascending offset.
    attr_reader :buckets

    # @api private
    def initialize(strings, buckets)
      @string_table = strings
      @buckets = buckets
      @map_data = HMapData.new(buckets)
    end

    # @return [String] the serialized fields of the mafile
    def serialize
      @map_data.serialize + @string_table
    end

    # Write all mafile data to the given filename.
    # @param filename [String] the file to write to
    # @return [void]
    def write(path)
      contents = serialize
      Utils.update_changed_file(path, contents)
    end
  end
end
