# frozen_string_literal: false

module HMap
  class Command
    # hmap file reader cmd
    class Reader < Command
      self.summary = 'Read mapfile and puts result.'

      self.description = <<-DESC
      Read mapfile and puts result, header, buckets, string_table.
      DESC

      self.arguments = [
        # framework_p, r_header, r_m
        CLAide::Argument.new('--hmap-path', true)
      ]

      def initialize(argv)
        super
        mapfile_path = argv.option('hmap-path') || ''
        @mapfile_path = Pathname.new(mapfile_path).expand_path
      end

      def validate!
        super
        # banner! if help?
        raise "[hmapfile] Reader [ERROR]: --hmap-path #{@mapfile_path} no exist".red if @mapfile_path.nil?
      end

      def self.options
        [
          ['--hmap-path=/hmap/dir/file', 'The path of the hmap file']
        ].concat(super)
      end

      def run
        UserInterface.puts "\n[hmapfile] Reader start\n"
        if File.exist?(@mapfile_path)
          HMap::MapFileReader.new(@mapfile_path)
        else
          UserInterface.puts "\n[hmapfile] Reader input path: #{@mapfile_path} no such file!\n".red
        end
        UserInterface.puts "\n[hmapfile] Reader finish\n"
      end
    end
  end
end
