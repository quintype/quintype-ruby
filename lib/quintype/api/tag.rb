require 'uri'

class Api
  class Tag
    attr_reader :tag
    class << self

      def wrap_all(tags)
        tags ||= []
        tags.is_a?(Array) ?
          tags.map {|t| wrap(t)} :
          wrap(tags)
      end

      def wrap(tag)
        new(tag) if tag
      end

      def find_by_name(name)
        if tag = Api.tag_by_name(URI.encode(name))
          wrap(tag["tag"])
        end
      end

      def find_all_by_slug(slug)
        if response = Api.tags_by_slug(URI.encode(slug))
          wrap_all(response["tags"])
        end
      end
    end

    def initialize(tag)
      @tag = tag
    end

    def to_h(config={})
      self.tag
    end
  end
end
