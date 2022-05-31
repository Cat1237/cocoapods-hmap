RSpec.describe 'cocoapods-hmap hmap-reader' do
  path = File.expand_path('./Resources/all-target-headers.hmap', File.dirname(__FILE__))

  it 'reader' do
    # hmapfile reader --hmap-path=./LGObject.hmap
    HMap::Command.run(['reader', "--hmap-path=#{path}"])
 end
end
