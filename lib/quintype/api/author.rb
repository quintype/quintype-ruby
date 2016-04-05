class API
  class Author
    attr_reader :author
    class << self
      def wrap_all(authors)
        authors ||= []
        authors.is_a?(Array) ?
          authors.map { |a| wrap(a) } :
          wrap(authors)
      end

      def wrap(author)
        new(author) if author
      end

      def where(params)
        if params['ids'].kind_of? Array
          params['ids'] = params['ids'].join ","
        end
        authors = API.authors(params)
        wrap_all(authors)
      end

      def find(params)
        if authors = API.authors({ids: params}).presence
          author = authors.first
          wrap(author)
        end
      end
    end

    def initialize(author)
      @author = author
    end

    def to_h(config={})
      author
    end

    private
  end
end