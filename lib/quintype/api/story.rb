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

      def where(params, opts={})
        stories = API.stories(params, opts)
        wrap_all(stories)
      end

      def find(params, opts={})
        if stories = API.stories(params, opts).presence
          story = stories.first
          wrap(story)
        end
      end

      def find_by_stacks(stacks, options={})
        if stacks.present?
          requests = stacks.inject({}) do |hash, stack|
            options.reject! {|k,v| k == 'section' }
            hash[stack['story_group']] = { 'story_group' => stack['story_group'] }.merge(options)
            hash
          end

          stories = find_in_bulk(requests)
          stories
        end
      end

      def find_in_bulk(params)
        if params.present?
          params = params.inject({}) do |hash, param|
            hash[param.first] = param.last.merge(_type: param.last[:_type] || 'stories')
            hash
          end
          response = API.bulk_post(requests: params)
          response['results']
        else
          []
        end
      end

      def find_by_slug(slug, params = {})
        if story = API.story_by_slug(slug, params).presence
          wrap(story['story'])
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

    def to_h(config={})
      hash = story.merge({
        'url' => URL.story(story),
        'time_in_minutes' => time_in_minutes,
        'tags' => add_urls_to_tags
      })
      if config.present?
        hash.merge!({ 'sections' => add_display_names_to_sections(config),
                      'canonical_url' => URL.story_canonical(config['root_url'], story)
                    })
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

    def add_urls_to_tags
      if story['tags'].present?
        tags = story['tags'].map do |tag|
          tag.merge('url' => URL.topic(tag['name']))
        end
      else
        story['tags']
      end
    end
  end
end
