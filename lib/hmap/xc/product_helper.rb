# frozen_string_literal: true
require 'hmap/xc/resolver'
module HMap
  class ProductPath
    attr_reader :path, :build_setting, :name

    def initialize(path)
      @path = path
      raise ArgumentError, "#{path}: can not get build directory" if @build_setting.nil?
    end

    def build_root
      Pathname(build_setting[Constants::BUILD_DIR])
    end

    def obj_root
      Pathname(build_setting[Constants::OBJROOT])
    end
  end

  class WorkspaceProductPath < ProductPath
    def initialize(path)
      @name = File.basename(path, '.xcworkspace')
      @build_setting = Resolver.instance.workspace_build_settings(path)
      super
    end
  end

  class ProjectProductPath < ProductPath
    def initialize(path)
      @name = File.basename(path, '.xcodeproj')
      @build_setting = Resolver.instance.project_build_settings(path)
      super
    end
  end
end
