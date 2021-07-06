# frozen_string_literal: true

require 'cocoapods-hmap/command/hmap_gen'
require 'cocoapods-hmap/command/hmap_reader'

module Pod
  # hook
  module CocoaPodsHMapHook
    HooksManager.register('cocoapods-mapfile', :post_install) do
      Command::HMapGen.run(["--project-directory=#{Config.instance.installation_root}", "--nosave-origin-header-search-paths"])
    end
  end
end
