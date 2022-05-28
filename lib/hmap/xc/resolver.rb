# frozen_string_literal: true

require 'hmap/helper/executable'

module HMap
  class Resolver
    # @return [Array<String>] The filenames that the Podfile can have ordered
    #         by priority.
    #
    PODFILE_NAMES = [
      'CocoaPods.podfile.yaml',
      'CocoaPods.podfile',
      'Podfile',
      'Podfile.rb'
    ].freeze

    attr_accessor :use_origin

    def self.instance
      @instance ||= new
    end

    # Sets the current config instance. If set to nil the config will be
    # recreated when needed.
    #
    # @param  [Config, Nil] the instance.
    #
    # @return [void]
    #
    class << self
      attr_writer :instance
    end

    def workspace_build_settings(workspace)
      workspace_dic = xcodebuild_list(workspace)['workspace']
      schemes = workspace_dic['schemes'] || []
      targets = xcodebuild_workspace(workspace, schemes[0]) || []
      targets.first['buildSettings']
    end

    def project_build_settings(project_path)
      targets = xcodebuild(project_path) || []
      targets.first['buildSettings']
    end

    # @return [Pathname] the root of the workspace or project where is located.
    #
    def installation_root
      @installation_root ||= begin
        current_dir = Pathname.new(Dir.pwd.unicode_normalize)
        current_path = current_dir
        until current_path.root?
          if podfile_path_in_dir(current_path)
            installation_root = current_path
            puts("[in #{current_path}]") unless current_path == current_dir
            break
          else
            current_path = current_path.parent
          end
        end
        installation_root || current_dir
      end
    end

    attr_writer :installation_root
    alias project_root installation_root

    def verbose?
      false
    end

    # @return [String] Executes xcodebuild list in the current working directory and
    #         returns its output (both STDOUT and STDERR).
    #
    def xcodebuild_list(workspace)
      command = %W[-workspace #{workspace}]
      command += %w[-json -list]
      results = Executable.execute_command('xcodebuild', command, false)
      JSON.parse(results) unless results.nil?
    end

    # @return [hash] Executes xcodebuild -workspace -scheme in the current working directory and
    #         returns its output (both STDOUT and STDERR).
    #
    def xcodebuild_workspace(workspace, scheme)
      command = %W[-workspace #{workspace}]
      command += %W[-scheme #{scheme}]
      xcodebuild(command)
    end

    # @return [hash] Executes xcodebuild -project in the current working directory and
    #         returns its output (both STDOUT and STDERR).
    #
    def xcodebuild_project(project)
      command = %W[-project #{project}]
      xcodebuild(command)
    end

    private

    # Returns the path of the Podfile in the given dir if any exists.
    #
    # @param  [Pathname] dir
    #         The directory where to look for the Podfile.
    #
    # @return [Pathname] The path of the Podfile.
    # @return [Nil] If not Podfile was found in the given dir
    #
    def podfile_path_in_dir(dir)
      PODFILE_NAMES.each do |filename|
        candidate = dir + filename
        return candidate if candidate.file?
      end
      nil
    end

    # @return [hash] Executes xcodebuild in the current working directory, get build settings and
    #         returns its output as hash  (both STDOUT and STDERR).
    #
    def xcodebuild(command)
      command += %w[-json -showBuildSettings]
      results = Executable.execute_command('xcodebuild', command, false)
      index = results.index(/"action"/m)
      reg = results[index..]
      reg = "[\n{\n#{reg}"
      JSON.parse(reg) unless results.nil?
    end
  end
end
