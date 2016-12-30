# coding: utf-8
require_relative '../../lib/quintype/api/stack'

describe Api::Stack do
  describe '#all', :vcr => { cassette_name: "api_stack_all" } do
    it 'gives all stacks' do
      stacks = described_class.all
      expect(stacks.count).to be > 0
    end
  end

  describe '#with_stories' do
    it 'gives all stacks with stories', :vcr => { cassette_name: "api_stack_with_stories" } do
      stacks = described_class.with_stories
      expect(stacks.count).to be > 0
      stacks.each do |stack|
        expect(stack['stories'].count).to be > 0
      end
    end

    it 'gives all stacks with stories with params', :vcr => { cassette_name: "api_stack_stories_with_params" } do
      stacks = described_class.with_stories({ 'section' => 'India' })
      expect(stacks.count).to be > 0
      stacks.each do |stack|
        expect(stack['stories'].count).to be > 0
      end
    end
  end
end
