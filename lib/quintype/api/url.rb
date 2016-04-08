class API
  class URL
    class << self
      def story (story)
        "/" + story['slug']
      end

      def story_canonical(root, story)
        root + story['slug']
      end

      def topic (tag_name)
        "/topic/" + encode_uri_component(tag_name)
      end

      def section (section_name)
        "/section/" + make_slug(section_name)
      end

      def search (term)
        "/search?q=" + term
      end

      def author (args)
        id = args['id']
        slug = args['slug']

        "/author/#{id}/#{slug}"
      end

      def encode_uri_component(s)
        URI.escape(s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")) if s
      end

      private

        def make_slug(s)
          s.gsub(/[^\w -]/, "").gsub(/\s+/, "-").downcase if s
        end
    end
  end
end
