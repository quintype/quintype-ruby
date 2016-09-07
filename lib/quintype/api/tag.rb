require 'uri'

class API
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
        if tag = API.tag_by_name(URI.encode(name))
          wrap(tag)
        end
      end
    end

    def initialize(tag)
      @tag = tag
    end

    def to_h(config={})
      self.tag["tag"]
    end
  end
end
