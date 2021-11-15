# frozen_string_literal: true

require 'hmap'

module Pod
  # hook
  @HooksManager = HooksManager
  @HooksManager.register('cocoapods-mapfile', :post_install) do |_, _options|
    args = ['gen', "--project-directory=#{Config.instance.installation_root}"]
    # allow_targets = options['allow_targets']
    # unless allow_targets.nil?
    #   if allow_targets.is_a?(Array)
    #     args << "--allow-targets=#{allow_targets.join(', ')}" unless allow_targets.empty?
    #   else
    #     print 'waring:'.yellow, \
    #           'plugin cocoapods-mapfile args allow_targets must be a array, like ## allow_targets: [target1, targte2] ##'
    #   end
    # end
    # save_origin = options['save_oripodgin'].nil? ? true : options['save_origin']
    # use_origin_headermap = options['use_origin_headermap'].nil? ? true : options['use_origin_headermap']
    # args << '--fno-save-origin' unless save_origin
    # args << '--fno-use-origin-headermap' unless use_origin_headermap
    HMap::Command.run(args)
  end
end
