# frozen_string_literal: true

require 'cocoapods_hmap'
require 'cocoapods'


module Pod
  class Command
    class HMapGen < Command
      self.summary = 'Analyzes the dependencies and gen each dependencie mapfile.'

      self.description = <<-DESC
      Analyzes the dependencies of any cocoapods projects and gen each dependencie mapfile.
      DESC

      def initialize(argv)
        super
        project_directory = argv.option('project-directory')
        unless project_directory.nil?
          @project_directory = Pathname.new(project_directory).expand_path
          config.installation_root = @project_directory
        end
      end

      def validate!
        super
        verify_podfile_exists!
      end

      def self.options
        [
          ['--project-directory=/project/dir/', 'The path to the root of the project
            directory']
        ].concat(super)
      end

      def run
        UI.section "\n[hmap-gen] start.............." do
          HMap::MapFileWriter.new
        end
        UI.puts('[hmap-gen] finish..............')
      end
    end
  end
end
