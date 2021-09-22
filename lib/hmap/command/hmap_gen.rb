# frozen_string_literal: true

require 'hmap'

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
        targets = argv.option('allow-targets') || ''
        @allow_targets = targets.split(/{,\s*}/)
        @no_use_build_in_headermap = !argv.flag?('fno-use-origin-headermap', false)
        @save_origin_build_setting = !argv.flag?('fno-save-origin', false)
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
          ['--allow-targets=target, target1, target2', 'If we set --fno-use-origin-headermap and ' \
            '--fno-save-origin, we can use this option to decide which targets to use hmap file while keeping the initial settings'],
          ['--nosave-origin-header-search-paths',
           'This option will not save xcconfig origin [HEADER_SEARCH_PATHS] and put hmap file first'],
          ['--fno-use-origin-headermap',
           'This option will use  Xcode built-in options Use Header Maps and not use this code gen hmap file'],
          ['--clean-hmap', 'This option will clean up all hmap-gen setup for hmap.']
        ].concat(super)
      end

      def run
        UI.section "\n[hmap-gen] start.............." do
          HMap::MapFileWriter.new(@save_origin_build_setting,
                                  @clean_hmap,
                                  @allow_targets,
                                  use_build_in_headermap: @no_use_build_in_headermap)
        end
        UI.puts('[hmap-gen] finish..............')
      end
    end
  end
end
