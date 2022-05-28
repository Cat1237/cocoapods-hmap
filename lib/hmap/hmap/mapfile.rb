# frozen_string_literal: true

module HMap
  # hmap file writer
  class MapFile
    # @api private
    def initialize(strings, buckets, entries)
      @map_data = HMapData.new(strings, buckets, entries)
    end

    # @return [String] the serialized fields of the mafile
    def serialize
      @map_data.serialize
    end

    # Write all mafile data to the given filename.
    # @param filename [String] the file to write to
    # @return [void]
    def write(filepath, contents = nil)
      contents = serialize if contents.nil?
      Utils.update_changed_file(filepath, contents)
    end
  end
end
