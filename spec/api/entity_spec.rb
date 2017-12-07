require_relative '../../lib/quintype/api/entity'

describe API::Entity do
  describe '#all' do
    it 'returns all entities', vcr: { cassette_name: 'api_entity_all' } do
      result = described_class.all({})
      expect(result['entities'].count).to eq 20
    end
    it 'returns entities when limits are specified', vcr: { cassette_name: 'api_entity_all_limits' } do
      result = described_class.all(limit: 1)
      expect(result['entities'].count).to eq 1
    end
  end

  describe '#find' do
    it 'returns a single entity by id', vcr: { cassette_name: 'api_entity_id' } do
      result = described_class.find(45667)
      expect(result.count).to eq 1
    end
  end

  describe '#sub_entity' do
    it 'returns a subentity by entity-id and subentity-id', vcr: { cassette_name: 'api_entity_subentity'} do
      result = described_class.sub_entity(45667, 32728)
      expect(result.count).to eq 1
    end
  end
end
