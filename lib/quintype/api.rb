require 'faraday'
require 'json'
require 'active_support/all'

# API models
require_relative './api/story'
require_relative './api/stack'
require_relative './api/url'


class API
  class << self
    def establish_connection(host)
      @@host = host
      @@api_base = host + '/api/'
      @@conn = Faraday.new(url: host) do |faraday|
        faraday.response :logger
        faraday.adapter  Faraday.default_adapter
      end
    end

    def conn
      @@conn
    end

    def bulk_post(params)
      _post("bulk", params)
    end

    def config
      _get("config")
    end

    def story(story_id)
      _get("stories/#{story_id}")
    end

    def story_by_slug(slug)
      _get("stories-by-slug", { slug: slug })
    end

    def related_stories(story_id, section, fields = [])
      _get("related-stories?", {
             "story-id" => story_id,
             section: section,
             fields: make_fields(fields)
           })
    end

    def stories(params, options = {})
      url = options[:facets] ? "stories-with-facets" : "stories"
      _get(url, params)
    end

    def comments_and_likes(story_ids)
      if story_ids.present?
        _get("comments-and-votes/" + story_ids.join('|'))
      end
    end

    def videos
      _get("stories-by-template", {
             template: "video",
             limit: 12,
             fields: "hero-image-s3-key,hero-image-metadata,hero-image-caption,headline,slug"
           })
    end

    def search_story_collection(name, options)
      _get("story-collection", {
             name: name,
             type: "search",
             fields: "author-name,hero-image-s3-key,hero-image-metadata,hero-image-caption,headline,slug,sections,metadata"
           }.merge(options))
    end

    def story_collection(options)
      _get("story-collection", options)
    end

    def story_collection_by_tag(options)
      _get("story-collection/find-by-tag", options)
    end

    def post_comment(parent_comment_id, member_id, story_content_id, text)
      _post("comment", {
              "parent-comment-id" => parent_comment_id,
              "member-id"         => member_id,
              "story-content-id"  => story_content_id,
              "text"              => text
            })
    end

    def invite_users(emails, from_email, from_name)
      params = { emails: emails }
      params['from-email'] = from_email if from_email.present?
      params['from-name'] = from_name if from_name.present?

      _post("emails/invite", params)
    end

    def contact_publisher(params)
      _post("emails/contact", params)
    end

    def unsubscribe_publisher(params)
      _post("emails/unsubscribe", params)
    end

    def authors(author_ids)
      _get("authors", { ids: author_ids })
    end

    def author_profile(author_id)
      _get("author/#{author_id}")
    end

    def search(options)
      _get("search", options)
    end

    def subscribe(member, profile, payment)
      _post("subscribe", {
              member: member,
              profile: profile,
              payment: payment
            })
    end

    def unsubscribe(options)
      _post("unsubscribe", { options: options })
    end

    def save_member_metadata(metadata)
      _post("member/metadata", { metadata: metadata })
    end

    def check_email(email)
      _get("member/check", { email: email })
    end

    def signup_member(member)
      _post("member", member)
    end

    def login_member(auth)
      _post("member/login", auth)
    end

    def forgot_password(member)
      _post("member/forgot-password", member)
    end

    def reset_password(params)
      _post("member/password", params)
    end

    def vote_on_story (data)
      _post("stories/#{data[:story_id]}/votes", data)
    end

    def votes_on_story (options = {})
      _get("stories/#{story_id}/votes", options)
    end

    private

    def _post(url_path, body)
      response = @@conn.post(@@api_base + url_path) do |request|
        request.options.timeout = 20
        request.headers['Content-Type'] = 'application/json'
        request.body = body.to_json
      end

      body = JSON.parse(response.body)

      case body
      when Array
        body.map { |i| keywordize(i) }
      when Object
        keywordize body
      end
    end

    def _get(url_path, *args)
      response = @@conn.get(@@api_base + url_path, *args) { |request| request.options.timeout = 20 }
      body = JSON.parse(response.body)

      case body
      when Array
        body.map { |i| keywordize(i) }
      when Object
        keywordize body
      end
    end

    def keywordize(obj)
      obj.deep_transform_keys { |k| k.gsub('-', '_') }
    end

    def make_fields(arr)
      arr.join(',') if arr.present?
    end
  end
end
