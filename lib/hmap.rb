# frozen_string_literal: true

# The primary namespace for cocoapods-hmap.
module HMap
  require_relative 'hmap/version'
  require_relative 'hmap/hmap_struct'
  require_relative 'hmap/helper/pods_helper'
  require_relative 'hmap/exceptions'
  require_relative 'hmap/framework/framework_vfs'
  require_relative 'hmap/hmap_saver'
  require_relative 'hmap/pods_specification'
  require_relative 'hmap/helper/xcconfig_helper'
  require_relative 'hmap/helper/utils'
  require_relative 'hmap/helper/hmap_helper'
  require_relative 'hmap/helper/build_setting_constants'

  autoload :Command, 'hmap/command'
  autoload :MapFileReader, 'hmap/hmap_reader'
  autoload :MapFileWriter, 'hmap/hmap_writer'
  autoload :MapFile, 'hmap/mapfile'
  autoload :Executable, 'hmap/executable'
end
