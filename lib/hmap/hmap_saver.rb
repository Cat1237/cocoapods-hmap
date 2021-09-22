# frozen_string_literal: true

module HMap
  class HMapSaver
    attr_reader :string_table, :buckets, :headers

    def self.new_from_buckets(buckets)
      saver = new
      saver.add_to_buckets(buckets)
      saver
    end

    def initialize
      @string_table = "\0"
      @buckets = []
      @headers = {}
    end

    def header_to_hash(keys, headers, index, buckets)
      index = index.length
      keys.inject('') do |sum, bucket|
        buckte = HMapBucketStr.new(*bucket)
        string_t = buckte.bucket_to_string(headers, index + sum.length)
        buckets.push(buckte)
        sum + string_t
      end
    end

    def add_to_string_table(str)
      @string_table += "#{Utils.safe_encode(str, 'ASCII-8BIT')}\0"
    end

    def add_to_headers(key)
      if headers[key].nil?
        headers[key] = string_table.length
        add_to_string_table(key)
      end
      headers[key]
    end

    def add_to_bucket(buckets)
      values = buckets.map { |key| add_to_headers(key) }
      bucket = HMapBucket.new(*values)
      bucket.uuid = Utils.string_downcase_hash(buckets.first)
      @buckets << bucket
    end

    def add_to_buckets(buckets)
      buckets.each { |bucket| add_to_bucket(bucket) }
    end

    def write_to(path)
      MapFile.new(@string_table, @buckets).write(path)
    end
  end
end
