require_relative '../../lib/quintype/api/story'

describe API::Story do
  describe '#find' , :vcr => { cassette_name: "api_story_find" } do
    it 'finds the stories for the required params' do
      story = described_class.find({limit: 1})
      expect(story.to_h).to_not be_empty
    end
  end

  describe '#where' , :vcr => { cassette_name: "api_story_find" } do
    it 'finds the stories for the required params' do
      stories = described_class.where({limit: 1})
      expect(stories.count).to eq 1
    end
  end

  describe '#all', :vcr => { cassette_name: "api_story_all" } do
    it 'gives all stories' do
      stories = described_class.all
      expect(stories.count).to eq 20
    end
  end

  describe '#all_video_stories', :vcr => { cassette_name: "api_stories_video" } do
    it 'gives all video stories' do
      stories = described_class.all_video_stories
      expect(stories.count).to eq 12
    end
  end

  describe '#find_by_slug', :vcr => { cassette_name: "api_stories_find_by_slug" } do
    it 'finds story for slug' do
      test_story = described_class.where({limit: 1})
      slug = test_story[0].to_h['slug']
      story = described_class.find_by_slug(slug)
      expect(story.to_h['slug']).to eq slug
    end
  end

  describe '#find_by_stacks'  do
    it 'gives stories for stacks' , :vcr => { cassette_name: "api_story_find_by_stacks" } do
      config = API.config
      stacks_stories = described_class.find_by_stacks(config['stacks'])
      stack_names = config['stacks'].map { |s| s['story_group'] }
      expect(stacks_stories.keys).to eq(stack_names)
      stacks_stories.each_pair do |story_group, stories|
        expect(stories.count).to be > 0
      end
    end

    it 'gives stories for stacks for a params passed', :vcr => { cassette_name: "api_story_find_by_stacks_and_sections" } do
      config = API.config
      stacks_stories = described_class.find_by_stacks(config['stacks'], {'section' => 'India'})
      stack_names = config['stacks'].map { |s| s['story_group'] }
      expect(stacks_stories.keys).to eq(stack_names)
      stacks_stories.each_pair do |story_group, stories|
        expect(stories.count).to be > 0
      end
    end
  end

  describe '#time_in_minutes' , :vcr => { cassette_name: "api_story_find" } do
    it 'calculates the time taken to read the story' do
      stories = described_class.where({limit: 1})
      story = stories.first

      expect(story.time_in_minutes).to eq 2
    end
  end

  describe '#to_h' do
    it 'serializes stories' , :vcr => { cassette_name: "api_story_find" } do
      stories = described_class.where({limit: 1})
      expect(stories.first.to_h.keys).to include("url", "headline", "tags", "sections", "time_in_minutes")
    end

    it 'serializes stories based on config', :vcr => { cassette_name: "api_story_find_config" } do
      config = API.config
      stories = described_class.where({limit: 1})
      story = stories.first.story
      serialized_story = stories.first.to_h(config)

      expect(story['sections'].first.keys).to_not include("display_name")
      expect(story['sections'].first).to eq({"id"=>5, "name"=>"India"})
      expect(serialized_story.keys).to include("url", "headline", "tags", "sections", "time_in_minutes")
      expect(serialized_story['sections'].first.keys).to include("display_name")
      expect(serialized_story['sections'].first).to eq({"id"=>5, "name"=>"India", "display_name"=>"India"})
    end
  end
end
