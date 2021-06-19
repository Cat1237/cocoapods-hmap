# frozen_string_literal: true

# The primary namespace for cocoapods-hmap.
module HMap
  require_relative 'cocoapods-hmap/version'
  require_relative 'cocoapods-hmap/view'
  require_relative 'cocoapods-hmap/hmap_struct'
  require_relative 'cocoapods-hmap/utils'
  require_relative 'cocoapods-hmap/exceptions'

  autoload :MapFileReader, 'cocoapods-hmap/hmap_reader'
  autoload :MapFileWriter, 'cocoapods-hmap/hmap_writer'
  autoload :MapFile, 'cocoapods-hmap/mapfile'
end
