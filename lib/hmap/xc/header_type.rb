
require 'hmap/xc/header_entry'

module HMap
  module HeaderType
    def public_entrys
      return @public_entrys if defined?(@public_entrys)

      @public_entrys = entrys.select { |entry| entry.type == :Public }
    end

    def private_entrys
      return @private_entrys if defined?(@private_entrys)

      @private_entrys = entrys.select { |entry| entry.type == :Private }
    end

    def project_entrys
      return @project_entrys if defined?(@project_entrys)

      @project_entrys = entrys.select { |entry| entry.type == :Project }
    end

    def use_vfs?
      !public_entrys.empty? || !private_entrys.empty? || build_as_framework?
    end

    def headers_hash(*types)
      Hash[types.map { |type| [type, send(type)] }]
    end
  end
end
