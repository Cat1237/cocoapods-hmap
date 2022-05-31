# frozen_string_literal: true

require 'hmap/hmap/hmap_struct'
require 'hmap/hmap/mapfile'
require 'hashtable'

module HMap
  # @class HMapSaver
  class HMapSaver
    attr_reader :string_table

    def self.new_from_buckets(buckets)
      saver = new
      saver.add_to_buckets(buckets) unless buckets.empty?
      saver
    end

    def add_to_buckets(buckets)
      return if buckets.nil?

      hash_t = HashTable::HashTable.new_from_vlaue_placeholder(buckets.length, EMPTY_BUCKET, expand: true)
      ta = HashTable::StringHashTraits.new { |bs| HMapBucket.new(*bs).serialize }
      buckets.each_pair do |key, value|
        hash_t.set(key, value, ta)
      end
      @strings = ta.string_table
      @buckets = hash_t.values
      @entries = hash_t.num_entries
    end

    def write_to(path)
      MapFile.new(@strings, @buckets, @entries).write(Pathname(path))
    end
  end
end
