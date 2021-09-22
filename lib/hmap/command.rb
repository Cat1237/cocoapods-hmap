# frozen_string_literal: true

# The primary namespace for VFS.
module HMap
  require 'colored2'
  require 'claide'
  # The primary Command for VFS.
  class Command < CLAide::Command
    require 'hmap/command/hmap_writer'
    require 'hmap/command/hmap_reader'

    self.abstract_command = false
    self.command = 'hmapfile'
    self.version = VERSION
    self.description = 'Read or write header map file.'
    self.plugin_prefixes = %w[claide writer reader]

    def initialize(argv)
      super
      return if ansi_output?

      Colored2.disable!
      String.send(:define_method, :colorize) { |string, _| string }
    end
  end
end
