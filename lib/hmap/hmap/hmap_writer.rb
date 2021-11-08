# frozen_string_literal: true

require 'hmap/xc/workspace/workspace'

module HMap
  class HMapTarget
    attr_reader :name, :target
  end

  # Helper module which returns handle method from MapFileWriter.
  class MapFileWriter
    # @param save_origin_header_search_paths save_origin_header_search_paths
    # @param clean_hmap clean up all hmap setup
    # @param allow_targets this targets will save origin build setting
    # @param use_build_in_headermap option use Xcode header map
    def initialize(use_origin, project_root, clean_hmap)
      UserInterface.puts("[hmapfile] Workspace/project root: #{project_root}..............")
      UserInterface.puts("[hmapfile] Analyzing dependencies..............")
      Resolver.instance.installation_root = project_root
      Resolver.instance.use_origin = use_origin
      create_hmapfile(clean_hmap)
    end

    # Integrates the projects mapfile associated
    # with the App project and Pods project.
    #
    # @param  [clean] clean hmap dir @see #podfile
    # @return [void]
    #
    def create_hmapfile(clean)
      # {a,b}– Match pattern a or b.
      # Though this looks like a regular expression quantifier, it isn't.
      # For example, in regular expression, the pattern a{1,2} will match 1 or 2 'a' characters.
      # In globbing, it will match the string a1 or a2.
      paths = Dir.glob(File.join(Resolver.instance.installation_root, '*.{xcworkspace,xcodeproj}'))
      workspace_paths = paths.select { |f| File.extname(f) == '.xcworkspace' }
      xcs = if workspace_paths.nil?
              project_paths = paths.select { |f| File.extname(f) == '.xcodeproj' }
              Workspace.new_from_xcprojects(project_paths) unless project_paths.nil?
            else
              Workspace.new_from_xcworkspaces(workspace_paths)
            end
      xcs.each do |xc|
        if clean
          xc.remove_hmap_settings!
        else
          xc.write_save!
        end
      end
    end
  end
end
