# frozen_string_literal: true

require 'cocoapods_hmap'
require 'cocoapods'

module Pod
  class Command
    # hmap file gen cmd
    class HMapGen < Command
      # summary
      self.summary = 'Analyzes the dependencies and gen each dependencie mapfile.'

      self.description = <<-DESC
      Analyzes the dependencies of any cocoapods projects and gen each dependencie mapfile.
      DESC

      def initialize(argv)
        super
        project_directory = argv.option('project-directory')
        @save_origin_header_search_paths = !argv.flag?('nosave-origin-header-search-paths', false)
        @clean_hmap = argv.flag?('clean-hmap', false)

        return if project_directory.nil?

        @project_directory = Pathname.new(project_directory).expand_path
        config.installation_root = @project_directory
      end

      def validate!
        super
        verify_podfile_exists!
      end

      # help
      def self.options
        [
          ['--project-directory=/project/dir/', 'The path to the root of the project
            directory'],
          ['--nosave-origin-header-search-paths', 'This option will not save xcconfig origin
          [HEADER_SEARCH_PATHS] and put hmap file first'],
          ['--clean-hmap', 'This option will clean up all hmap-gen setup for hmap.']
        ].concat(super)
      end

      def run
        UI.section "\n[hmap-gen] start.............." do
          HMap::MapFileWriter.new(@save_origin_header_search_paths, @clean_hmap)
        end
        UI.puts('[hmap-gen] finish..............')
      end
    end
  end
end
