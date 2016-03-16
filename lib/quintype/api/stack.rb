class API
  class Stack
    class << self
      def all
        API.config['stacks']
      end
      #TODO filter by stacks
      def with_stories(params={}, config={})
        stories_with_stacks = API::Story.find_by_stacks(all, params)
        stacks = all.map do |stack|
          stories = stories_with_stacks[stack['story_group']]
          if config.present?
            stories = stories.map {|story| story.to_h(config) }
          end
          stack['stories'] = stories
          stack
        end
      end
    end
  end
end
