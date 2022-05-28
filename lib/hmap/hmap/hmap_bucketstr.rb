# frozen_string_literal: true

module HMap
  # hmap bucket string
  class BucketStr
    attr_reader :key, :perfix, :suffix

    def initialize(key, perfix, suffix)
      @key = key
      @perfix = perfix
      @suffix = suffix
    end

    def value
      [perfix, suffix]
    end

    def to_a
      [key, perfix, suffix]
    end

    def description
      <<-DESC
        Key #{@key} -> Prefix #{@perfix}, Suffix #{@suffix}
      DESC
    end
  end
end
