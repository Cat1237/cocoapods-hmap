module HMap
  class HeaderEntry
    attr_reader :path, :extra_keys, :type

    def initialize(path, extra_keys, type)
      @path = path
      @extra_keys = extra_keys
      @type = type
    end

    def project_buckets
      h_name = File.basename(path)
      h_dir = File.dirname(path)
      [BucketStr.new(h_name, "#{h_dir}/", h_name)]
    end

    def module_buckets(moudle_name)
      h_name = File.basename(path)
      module_p = "#{moudle_name}/"
      [BucketStr.new(h_name, module_p, h_name)]
    end

    def full_module_buckets(moudle_name)
      h_name = File.basename(path)
      h_dir = File.dirname(path)
      module_k = "#{moudle_name}/#{h_name}"
      [BucketStr.new(module_k, "#{h_dir}/", h_name)]
    end

    def project_buckets_extra
      h_name = File.basename(path)
      h_dir = File.dirname(path)
      buckets = []
      buckets << BucketStr.new(h_name, "#{h_dir}/", h_name) unless extra_keys.include?(h_name)
      buckets + extra_keys.map { |key| BucketStr.new(key, "#{h_dir}/", h_name) }
    end

    def module_buckets_extra(moudle_name)
      h_name = File.basename(path)
      module_p = "#{moudle_name}/"
      buckets = []
      buckets << BucketStr.new(h_name, module_p, h_name) unless extra_keys.include?(h_name)
      buckets + extra_keys.map { |key| BucketStr.new(key, module_p, h_name) }
    end

    def full_module_buckets_extra(moudle_name)
      h_name = File.basename(path)
      h_dir = File.dirname(path)
      module_k = "#{moudle_name}/#{h_name}"
      buckets = []
      buckets << BucketStr.new(module_k, "#{h_dir}/", h_name) unless extra_keys.include?(module_k)
      buckets + extra_keys.map { |key| BucketStr.new(key, "#{h_dir}/", h_name) }
    end
  end
end
