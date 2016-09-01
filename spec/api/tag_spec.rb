require_relative '../../lib/quintype/api/tag'

describe API::Tag do
  describe '#find_by_name' , :vcr => { cassette_name: "api_tag_find" } do
    it 'finds the tag by name' do
      tag = described_class.find_by_name({name: "bloomberg"})
      expect(tag.to_h).to_not be_empty
    end
  end


  describe '#to_h' do
    it 'has tag', :vcr => { cassette_name: "api_tag_find" } do
      tag = described_class.find_by_name({name: "bloomberg"})
      expect(tag.to_h.keys).to include("tag")
    end

    it 'serializes tag' , :vcr => { cassette_name: "api_tag_find" } do
      tag = described_class.find_by_name({name: "bloomberg"})
      expect(tag.to_h["tag"].keys).to include("name", "meta_description")
    end
  end
end



