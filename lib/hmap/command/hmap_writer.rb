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
        @json_path = argv.option('json-path') || ''
        output_path = argv.option('output-path')
        @output_path = output_path.nil? ? Pathname('.') : Pathname(output_path)
      end

      def validate!
        super
        help! 'error: no input json files which to use with the `--json-path` option.' if @json_path.nil?
        help! 'error: no output path which to use the `--output-path`' if @output_path.nil?
      end

      # help
      def self.options
        [
          ['--json-path=/project/dir/json', 'The path to the hmap json data.'],
          ['--output-path=/project/dir/hmap file', 'The path json data to the hmap file.']
        ].concat(super)
      end

      def run
        UserInterface.puts "\n[hmapfile-from-json] start"
        if File.exist?(@json_path)
          require 'json'
          json_file = File.read(@json_path)
          json = JSON.parse(json_file)
          path = @output_path
          path = path.join("#{File.basename(@json_path, '.*')}.hmap") if path.directory?
          HMapSaver.new_from_buckets(json).write_to(path)
          UserInterface.puts "[hmapfile-from-json] output path #{path}".green
        else
          unless File.exist?(@json_path)
            UserInterface.puts "\n[hmapfile-from-json] Error json path: #{@json_path} no such file!".red
          end
          unless File.exist?(@output_path)
            UserInterface.puts "\n[hmapfile-from-json] Error output path: #{@output_path} no such file!".red
          end
        end
        UserInterface.puts "\n[hmapfile-from-json] finish"
      end
    end
  end
end
