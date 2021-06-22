# frozen_string_literal: false

require 'cocoapods_hmap'
require 'cocoapods'

module Pod
  class Command
    # hmap file reader cmd
    class HMapReader < Command
      self.summary = 'Read mapfile and puts result.'

      self.description = <<-DESC
      Read mapfile and puts result, header, buckets, string_table.
      DESC

      def initialize(argv)
        super
        mapfile_path = argv.option('hmap-path')
        @mapfile_path = Pathname.new(mapfile_path).expand_path unless mapfile_path.nil?
      end

      def validate!
        super
        banner! if help?
        raise '[ERROR]: --hmap-path no set'.red unless File.exist?(@mapfile_path)
      end

      def self.options
        [
          ['--hmap-path=/hmap/dir/file', 'The path of the hmap file']
        ].concat(super)
      end

      def run
        UI.section "\n[hmap-reader] start..............\n".yellow do
          HMap::MapFileReader.new(@mapfile_path)
        end
        UI.puts("\n[hmap-reader] finish..............\n".yellow)
      end
    end
  end
end
