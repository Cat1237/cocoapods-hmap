RSpec.describe 'cocoapods-hmap hmap-reader' do
  path = File.expand_path('./Resources/All-Pods-Public-hmap.hmap', File.dirname(__FILE__))
  expect(File.file?(path))

  reader = HMap::MapFileReader.new(path.to_s)

  it 'bucktes count' do
    expect(reader.header.num_buckets == 256)
  end

  it 'String table entry count' do
    expect(reader.header.num_entries == 154)
  end
end
