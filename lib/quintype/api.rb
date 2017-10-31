require 'faraday'
require 'json'
require 'active_support/all'

# API models
require_relative './api/story'
require_relative './api/stack'
require_relative './api/url'

class API
  class << self
    def establish_connection(host, conn = Faraday.new(url: host))
      @@host = host
      @@api_base = host + '/api/'
      @@bulk_cache ||= ActiveSupport::Cache::MemoryStore.new
      @@conn = conn
    end

    def conn
      @@conn
    end

    def bulk_post(params)
      _post("bulk", params)
    end

    def bulk_cached(params)
      response_body = nil # Used in case of manticore auto following redirect. Ugly side effect

      location = @@bulk_cache.fetch(params) do |params|
        response = @@conn.post(@@api_base + "bulk-request", params) do |request|
          request.headers['Content-Type'] = 'application/json'
          request.body = params.to_json
        end

        if response.status == 303 && response.headers["Location"]
          response.headers["Location"]
        elsif response.status == 200 && response.headers["Content-Location"]
          response_body = keywordize(JSON.parse(response.body))
          log_warning("The faraday adapter is configured to follow redirects by default. Using the Content-Location header")
          response.headers["Content-Location"]
        else
          raise "Did not recieve a location header, status #{response.status}"
        end
      end

      response_body || _get(location.sub(/^\/api\//, ""))
    end

    def config
      _get("config")
    end

    def sections
      _get("sections")
    end

    def story(story_id)
      _get("stories/#{story_id}")
    end

    def slugify(x)
      _get("slugify/#{x}")
    end

    def tag_by_name(tag_name)
      _get("tag/#{tag_name}")
    end

    def story_by_slug(slug, params = {})
      _get("stories-by-slug", params.merge({ slug: slug }))
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

    # This is a hack because we can't migrate entire APIs to use v1 [Varun - 14th December 2016]
    def collection(slug, options)
      _get("v1/collections/" + slug, options)
    end

    def story_collection(options)
      _get("story-collection", options)
    end

    def story_collection_by_tag(options)
      _get("story-collection/find-by-tag", options)
    end

    def post_comment(story_content_id, text, parent_comment_id=nil, session_cookie)
      hash = {
        "story-content-id"  => story_content_id,
        "text"              => text
      }
      hash.merge!("parent-comment-id" => parent_comment_id.to_i) if parent_comment_id
      _post("comment", hash, session_cookie)
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

    def authors(params)
      _get("authors", params)
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

    def save_member_metadata(metadata, session_cookie)
      _post("member/metadata", { metadata: metadata }, session_cookie)
    end

    def get_member_metadata(session_cookie)
      _get("member/metadata", {}, { auth_token: session_cookie})
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

    def login(provider, data)
      user, headers = _post_returning_headers("login/#{provider}", data)
      user['auth_token'] = headers['X-QT-AUTH']
      user['member'].merge(user.except('member'))
    end

    def logout
      _get("logout")
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

    def preview_story(public_preview_key)
      _get("v1/preview/story/#{public_preview_key}")
    end

    private

    def _post(url_path, body, session_cookie=nil)
      body, headers = _post_returning_headers(url_path, body, session_cookie)

      body
    end

    def _post_returning_headers(url_path, body, session_cookie=nil)
      response = @@conn.post(@@api_base + url_path) do |request|
        request.headers['Content-Type'] = 'application/json'
        request.headers['X-QT-AUTH'] = session_cookie if session_cookie

        request.body = body.to_json
      end

      if response.body.present?
        body = case body = JSON.parse(response.body)
               when Array
                 body.map { |i| keywordize(i) }
               when Object
                 keywordize body
               end

        [body, response.headers]
      end
    end

    def _get(url_path, params={}, args={})
      response = @@conn.get(@@api_base + url_path, params) do |request|
        request.headers['Content-Type'] = 'application/json'
        request.headers['X-QT-AUTH'] = args[:auth_token] if args[:auth_token]
      end

      return nil if response.status >= 400

      if response.body.present?
        body = JSON.parse(response.body)

        case body
        when Array
          body.map { |i| keywordize(i) }
        when Object
          keywordize body
        end
      end
    end

    def keywordize(obj)
      obj.deep_transform_keys { |k| k.gsub('-', '_') }
    end

    def make_fields(arr)
      arr.join(',') if arr.present?
    end

    def log_warning(*args)
      return unless defined?(Rails)
      Rails.logger.warn(*args)
    end
  end
end
