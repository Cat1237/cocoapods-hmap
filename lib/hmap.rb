# frozen_string_literal: true

require 'xcodeproj'

# The primary namespace for cocoapods-hmap.
module HMap
  require 'pathname'
  require 'claide'

  require_relative 'hmap/version'
  require_relative 'hmap/user_interface'

  # autoload registers a file path to be loaded the first time
  # that a specified module or class is accessed in the namespace of the calling module or class.
  autoload :Command, 'hmap/command'
  autoload :Utils, 'hmap/helper/utils'
  autoload :Constants, 'hmap/constants'
  autoload :BucketStr, 'hmap/hmap/hmap_bucketstr'
  autoload :HMapSaver, 'hmap/hmap/hmap_saver'
  autoload :MapFileWriter, 'hmap/hmap/hmap_writer'
  autoload :MapFileReader, 'hmap/hmap/hmap_reader'

  # autoload :Struct, 'hmap/hmap/hmap_struct'
end
