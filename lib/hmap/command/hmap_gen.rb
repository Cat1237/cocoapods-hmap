# frozen_string_literal: true

module HMap
  class Command
    # hmap file gen cmd
    class Gen < Command
      # summary
      self.summary = 'Analyzes the dependencies and gen each dependencie hmap file.'

      self.description = <<-DESC
      Analyzes the dependencies of any projects and gen each dependencie hmap file.
      DESC

      self.arguments = [
        CLAide::Argument.new('--project-directory', false),
        CLAide::Argument.new('--clean-hmap', false)
      ]

      def initialize(argv)
        super
        project_directory = argv.option('project-directory')
        @clean_hmap = argv.flag?('clean-hmap', false)
        project_directory = Dir.pwd if project_directory.nil?
        @project_directory = Pathname.new(project_directory).expand_path
      end

      def validate!
        super
        if @project_directory.nil?
          help! 'error: no input project directory which to use with the `--project-directory` option.'
        end
      end

      # help
      def self.options
        [
          ['--project-directory=/project/dir/', 'The path to the root of the project directory'],
          ['--clean-hmap', 'This option will clean up all hmap-gen setup for hmap.']
        ].concat(super)
      end

      def run
        name = 'Gen'
        name = 'Clean' if @clean_hmap
        UserInterface.puts("\n[hmapfile] #{name} start")
        unless @project_directory.exist?
          UserInterface.puts("\n[hmapfile] #{name} #{@project_directory} dir not exist!".red)
          return
        end
        HMap::MapFileWriter.new(true, @project_directory, @clean_hmap)
        UserInterface.puts("[hmapfile] #{name} finish")
      end
    end
  end
end
