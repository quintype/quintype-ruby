class API
  class Stack
    class << self
      def all
        API.config['layout']['stacks']
      end

      def with_stories(params={})
        stories_with_stacks = API::Story.find_by_stacks(all, params)
        stacks = all.map do |stack|
          stack['stories'] = stories_with_stacks[stack['story_group']]
          stack
        end
      end
    end
  end
end
