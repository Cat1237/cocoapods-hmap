RSpec.describe 'cocoapods-hmap hmap-reader' do
  path = File.expand_path('./Resources/mm.json', File.dirname(__FILE__))
  output = File.expand_path('./Resources/all-target-headers.hmap', File.dirname(__FILE__))

  it 'writer' do
    # hmapfile writer --json-path=./mm.json --output-path=./LGObject.hmap
    HMap::Command.run(['writer', "--json-path=#{path}", "--output-path=#{output}"])
  end
end
