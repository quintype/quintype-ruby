require_relative './story/reading_time'

class API
  class Story
    attr_reader :story
    include ReadingTime
    class << self
      def wrap_all(stories)
        stories ||= []
        stories.is_a?(Array) ?
          stories.map { |s| wrap(s) } :
          wrap(stories)
      end

      def wrap(story)
        new(story) if story
      end

      def find(params, opts={})
        stories = API.stories(params, opts)
        wrap_all(stories)
      end

      def find_by_stacks(stacks, options={})
        if stacks.present?
          stacks.inject({}) do |hash, stack|
            stories = find({ 'story-group' => stack['story_group']}.merge(options)) || []
            hash[stack['story_group']] = stories
            hash
          end
        end
      end

      def all_video_stories
        stories = API.videos
        wrap_all(stories['stories'])
      end

      def all
        stories = API.stories({})
        wrap_all(stories)
      end
    end

    def initialize(story)
      @story = story
    end

    def cards
      @cards = story['cards'] || []
    end

    def serializable_hash(config={})
      hash = {
        'url' => add_url,
        'time_in_minutes' => time_in_minutes
      }.merge(story)
      if config.present?
        hash.merge!({ 'sections' => add_display_names_to_sections(config) })
      end
      hash
    end

    private
    def add_display_names_to_sections(config)
      return story unless story['sections'].present?

      sections = story['sections'].map do |section|
        display_section = config['sections'].find { |s| s['id'] == section['id'] } || {}

        display_name = display_section['display_name'] || display_section['name'] || section['name']

        section.merge({ 'display_name' => display_name })
      end
    end

    def add_url
      URL.story(story)
    end
  end
end
