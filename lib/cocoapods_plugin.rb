# frozen_string_literal: true

require 'hmap/command/hmap_gen'
require 'hmap/command/hmap_reader'

module Pod
  # hook
  module CocoaPodsHMapHook
    HooksManager.register('cocoapods-mapfile', :post_install) do
      Command::HMapGen.run(["--project-directory=#{Config.instance.installation_root}"])
    end
  end
end
