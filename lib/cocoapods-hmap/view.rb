# frozen_string_literal: true

module HMap
  # A representation of some unspecified hmap data.
  class HMapView
    # @return [String] the raw hmap data
    attr_reader :raw_data

    # @return [Symbol] the endianness of the data (`:big` or `:little`)
    attr_reader :endianness

    # @return [Integer] the offset of the relevant data (in {#raw_data})
    attr_reader :offset

    # Creates a new HMapView.
    # @param raw_data [String] the raw hmap data
    # @param endianness [Symbol] the endianness of the data
    # @param offset [Integer] the offset of the relevant data
    def initialize(raw_data, endianness, offset)
      @raw_data = raw_data
      @endianness = endianness
      @offset = offset
    end

    # @return [Hash] a hash representation of this {HMapView}.
    def to_h
      {
        'endianness' => endianness,
        'offset' => offset
      }
    end
  end
end
