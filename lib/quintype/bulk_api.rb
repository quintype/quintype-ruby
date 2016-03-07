class BulkAPI
  attr_reader :api

  def initialize(api)
    @api = api
  end

  def stories_for_stacks(story_groups, section_name)
    params = story_groups.reduce({}) do |acc, story_group|
      acc[story_group] = {
        'type' => '_stories',
        'section' => section_name,
        'story-group' => story_group
      }
      acc
    end

    api.bulk_post(params)
  end
end
