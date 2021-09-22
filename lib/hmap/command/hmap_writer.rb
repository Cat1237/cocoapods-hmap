# frozen_string_literal: true

module HMap
  class Command
    # hmap file gen cmd
    class Writer < Command
      # summary
      self.summary = 'Analyzes the input json and gen each dependencie mapfile.'

      self.description = <<-DESC
      Analyzes the input json and gen each dependencie mapfile.
      DESC

      self.arguments = [
        # framework_p, r_header, r_m
        CLAide::Argument.new('--json-path', true),
        CLAide::Argument.new('--output-path', false)
      ]

      def initialize(argv)
        super
        json_path = argv.option('json-path')
        @json_path = json_path unless json_path.nil?
        output_path = argv.option('output-path')
        @output_path = output_path.nil? ? Pathname('.') : Pathname(output_path)
      end

      def validate!
        super
        help! 'error: no input json files which to use with the `--json-path` option.' if @json_path.nil?
        help! "error: Input json file #{@json_path}: no such file" unless File.exist?(@json_path)
      end

      # help
      def self.options
        [
          ['--json-path=/project/dir/json', 'The path to the hmap json data.'],
          ['--output-path=/project/dir/hmap file', 'The path json data to the hmap file.']
        ].concat(super)
      end

      def run
        puts "\n[hmap-gen-from-json] start..............".yellow
        json_file = File.read(@json_path)
        json = JSON.parse(json_file)
        path = @output_path
        path = path.join("#{File.basename(@json_path, '.*')}.hmap") if path.directory?
        HMapSaver.new_from_buckets(json).write_to(path)
        puts '[hmap-gen-from-json] finish..............'.yellow
      end
    end
  end
end
