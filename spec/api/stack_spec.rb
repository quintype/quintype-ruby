# coding: utf-8
require_relative '../../lib/quintype/api/stack'

describe API::Stack do
  describe '#all', :vcr => { cassette_name: "api_stack_all" } do
    it 'gives all stacks' do
      stacks = described_class.all
      expect(stacks.count).to eq 5
    end
  end

  describe '#with_stories' do
    it 'gives all stacks with stories', :vcr => { cassette_name: "api_stack_with_stories" } do
      stacks = described_class.with_stories
      expect(stacks.count).to eq 5
      stacks.each do |stack|
        expect(stack.keys).to include('stories')
      end
      expect(stacks.last['stories'].first.story['headline']).to eq "#MyLoveStory: Caste’s the Villain in Tridip & Sudipa’s Filmy Saga"
    end

    it 'gives all stacks with stories with params', :vcr => { cassette_name: "api_stack_stories_with_params" } do
      stacks = described_class.with_stories({ 'section' => 'India' })
      expect(stacks.count).to eq 5
      stacks.each do |stack|
        expect(stack.keys).to include('stories')
      end
      expect(stacks.last['stories'].first.story['headline']).to eq "#MyLoveStory: Caste’s the Villain in Tridip & Sudipa’s Filmy Saga"
    end
  end
end
