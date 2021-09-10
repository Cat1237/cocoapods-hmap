RSpec.describe 'cocoapods-hmap hmap-reader' do
  path = File.expand_path('./Resources/All-Pods-Public-hmap.hmap', File.dirname(__FILE__))
  p File.file?(path)
  reader = HMap::MapFileReader.new(path.to_s)

  it 'bucktes count' do
    expect(reader.header.num_buckets == 256)
  end

  it 'String table entry count' do
    expect(reader.header.num_entries == 154)
  end
end

# HEADER_SEARCH_PATHS = ${HMAP_PODS_HEADER_SEARCH_PATHS}
# HMAP_PODS_HEADER_SEARCH_PATHS = -iquote "${PODS_ROOT}/Headers/WCDB.swift.build/WCDBSwift-generated-files.hmap" -I"${PODS_ROOT}/Headers/WCDB.swift.build/WCDBSwift-own-target-headers.hmap" -I"${PODS_ROOT}/Headers/WCDB.swift.build/WCDBSwift-all-non-framework-target-headers.hmap" -iquote "${PODS_ROOT}/Headers/WCDB.swift.build/WCDBSwift-project-headers.hmap"
# HMAP_PODS_OTHER_CFLAGS = $(inherited) -ivfsoverlay ${PODS_ROOT}/Headers/HMap/vfs/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)/all-product-headers.yaml