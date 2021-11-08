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
        mapfile_path = argv.option('hmap-path')
        raise ArgumentError, "#{mapfile_path}: no such file!" if mapfile_path.nil? || !File.exist?(mapfile_path)

        @mapfile_path = Pathname.new(mapfile_path).expand_path 
      end

      def validate!
        super
        # banner! if help?
        raise '[ERROR]: --hmap-path no set'.red unless File.exist?(@mapfile_path)
      end

      def self.options
        [
          ['--hmap-path=/hmap/dir/file', 'The path of the hmap file']
        ].concat(super)
      end

      def run
        UserInterface.puts "\n[hmapfile] Reader start..............\n".yellow
        HMap::MapFileReader.new(@mapfile_path)
        UserInterface.puts "\n[hmapfile] Reader finish..............\n".yellow
      end
    end
  end
end
