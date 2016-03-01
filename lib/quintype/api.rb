require 'faraday'
require 'json'
require 'active_support/all'

class API
  attr_reader :host, :conn

  def initialize(host)
    @host = host
    setup_connection
  end

  def api_base
    @api_base ||= host + '/api'
  end

  def setup_connection
    @conn = Faraday.new(url: host) do |faraday|
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
  end

  def config
    _get("#{api_base}/config")
  end

  def story(story_id)
    _get("/api/stories/#{story_id}")
  end

  def story_by_slug(slug)
    _get("/api/stories-by-slug", { slug: slug })
  end

  def related_stories(story_id, section, fields = [])
    _get("/api/related-stories?", {
      "story-id": story_id,
      section: section,
      fields: make_fields(fields)
    })
  end

  def stories(params, options = {})
    url = options[:facets] ? "/stories-with-facets" : "/stories"
    _get(api_base + url, params)
  end

  def comments_and_likes(story_ids)
    if story_ids.present?
      _get("#{api_base}/comments-and-votes/" + story_ids.join('|'))
    end
  end

  def videos
    _get("#{api_base}/stories-by-template", {
      template: "video",
      limit: 12,
      fields: "hero-image-s3-key,hero-image-metadata,hero-image-caption,headline,slug"
    })
  end

  def search_story_collection(name, options)
    _get("#{api_base}/story-collection", {
      name: name,
      type: "search",
      fields: "author-name,hero-image-s3-key,hero-image-metadata,hero-image-caption,headline,slug,sections,metadata"
    }.merge(options))
  end

  def story_collection(options)
    _get("#{api_base}/story-collection", options)
  end

  def story_collection_by_tag(options)
    _get("#{api_base}/story-collection/find-by-tag", options)
  end

  def post_comment(parent_comment_id, story_content_id, text)
    _post("#{api_base}/comment", {
      "parent-comment-id" => parent_comment_id,
      "member-id"         => global.sketches.member_id(),
      "story-content-id"  => story_content_id,
      "text"              => text
    })
  end

  def invite_users(emails, from_email, from_name)
    params = { emails: emails }
    params['from-email'] = from_email if from_email.present?
    params['from-name'] = from_name if from_name.present?

    _post("#{api_base}/emails/invite", params)
  end

  def contact_publisher(params)
    _post("#{api_base}/emails/contact", params)
  end

  def unsubscribe_publisher(params)
    _post("#{api_base}/emails/unsubscribe", params)
  end

  def authors(author_ids)
    _get("#{api_base}/authors", { ids: author_ids })
  end

  def author_profile(author_id)
    _get("#{api_base}/author/#{author_id}")
  end

  def search(options)
    _get("#{api_base}/search", options)
  end

  def subscribe(member, profile, payment)
    _post("#{api_base}/subscribe", {
      member: member,
      profile: profile,
      payment: payment
    })
  end

  def unsubscribe(options)
    _post("#{api_base}/unsubscribe", { options: options })
  end

  def save_member_metadata(metadata)
    _post("#{api_base}/member/metadata", { metadata: metadata })
  end

  def check_email(email)
    _get("#{api_base}/member/check", { email: email })
  end

  def signup_member(member)
    _post("#{api_base}/member", member)
  end

  def login_member(auth)
    _post("#{api_base}/member/login", auth)
  end

  def forgot_password(member)
    _post("#{api_base}/member/forgot-password", member)
  end

  def reset_password(params)
    _post("#{api_base}/member/password", params)
  end

  def vote_on_story (data)
    _post("#{api_base}/stories/#{data[:story_id]}/votes", data)
  end

  def votes_on_story (options = {})
    _get("#{api_base}/stories/#{story_id}/votes", options)
  end

  private

  def _post(*args)
    response = conn.post(*args)
    body = JSON.parse(response.body)

    case body
    when Array
      body.map { |i| keywordize(i) }
    when Object
      keywordize body
    end
  end

  def _get(*args)
    response = conn.get(*args) { |request| request.options.timeout = 20 }
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
