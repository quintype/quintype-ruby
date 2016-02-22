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
      # faraday.request  :url_encoded
      faraday.request :retry, max: 0, interval: 5
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
  end

  def config
    _get("#{api_base}/config")
  end

  # def post_comment(parent_comment_id, story_content_id, card_content_id, text)
  #   _post("/api/comment")
  #     .send({
  #           "parent-comment-id" => parent_comment_id,
  #           "member-id"         => global.sketches.member_id(),
  #           "story-content-id"  => story_content_id,
  #           "card-content-id"   => card_content_id,
  #           "text"              => text
  #         })
  # end

  # def fetch_story(story_content_id)
  #   _get("/api/stories/#{story_content_id}")
  # end

  def stories(options)
    _get("#{api_base}/stories", options)
  end

  # def fetch_stories_with_facets(options)
  #   _get("/api/stories-with-facets")
  #     .timeout(5000)
  #     .query(options)
  # end

  # def fetch_comments_and_likes(story_content_ids)
  #   if (story_content_ids.length !== 0)
  #     _get(global.sketches.config["sketches-host"] + "/api/comments-and-votes/" + story_content_ids.join("|"))


  # end

  # def fetch_videos(callback, error)
  #   _get("/api/stories-by-template")
  #     .timeout(5000)
  #     .query(
  #       template: "video", limit: 12,
  #       fields  : "hero-image-s3-key,hero-image-metadata,hero-image-caption,headline,slug"
  #     )

  # end

  # def fetch_search_story_collection(name, options)
  #   _get("/api/story-collection")
  #     .timeout(5000)
  #     .query(_.assign(
  #       name  : name,
  #       type: "search",
  #       fields: "author-name,hero-image-s3-key,hero-image-metadata,hero-image-caption,headline,slug,sections,metadata"
  #     end options))

  # end

  # def fetch_story_collection(options)
  #   _get("/api/story-collection")
  #     .timeout(5000)
  #     .query(options)

  # end

  # def fetch_config(callback, error)
  #   _get("/api/config")
  #     .timeout(5000)

  # end

  # def fetch_story_collection_by_tag(options)
  #   _get("/api/story-collection/find-by-tag")
  #     .timeout(5000)
  #     .query(options)

  # end

  # # def post_upvote(story_content_id, comment_id)
  # #   _post("/api/upvote")
  # #     .send(
  # #       "member-id"       : global.sketches.member_id(),
  # #       "story-content-id": story_content_id,
  # #       "comment-id"      : comment_id,
  # #       "card-content-id" : null
  # #     )
  # #
  # # end

  # # def post_downvote(story_content_id, comment_id)
  # #   _post("/api/downvote")
  # #     .send(
  # #       "member-id"       : global.sketches.member_id(),
  # #       "story-content-id": story_content_id,
  # #       "comment-id"      : comment_id,
  # #       "card-content-id" : null
  # #     )
  # #
  # # end

  # def post_card_comment: post_comment,

  # def post_story_comment(parent_comment_id, story_content_id, text)
  #   post_comment(parent_comment_id, story_content_id, null, text)
  # end

  # def invite_users(emails, from_email, from_name)
  #    params =
  #     emails: emails


  # def   if (!_.is_empty(from_email))
  #     params['from-email'] = from_email

  #   if (!_.is_empty(from_name))
  #     params['from-name'] = from_name


  # def   _post("/api/emails/invite")
  #     .send(params)

  # end

  # def contact_publisher(params)
  #   _post("/api/emails/contact")
  #     .send(params)

  # end

  # def unsubscribe_publisher(params)
  #   _post("/api/emails/unsubscribe")
  #     .send(params)

  # end

  # def fetch_authors(author_ids)
  #   _get("/api/authors")
  #         .timeout(5000)
  #         .query(ids : author_ids)

  # end

  # def fetch_author_profile(author_id)
  #   _get(global.sketches.config["sketches-host"] + "/api/author/" + author_id)

  # end

  # def search_stories(options)
  #   _get(global.sketches.config["sketches-host"] + "/api/search")
  #     .timeout(5000)
  #     .query(options)

  # end

  # def subscribe (member, profile, payment)
  #   _post("/api/subscribe")
  #     .send(member: member, profile: profile, payment: payment)
  #     .timeout(5000)

  # end

  # def unsubscribe(options)
  #   _post("/api/unsubscribe")
  #     .send(options: options)
  #     .timeout(5000)

  # end

  # def save_member_metadata(metadata)
  #   _post("/api/member/metadata")
  #     .send( metadata: metadata )

  # end

  # def check_email(email)
  #   _get("/api/member/check")
  #     .query( email: email )

  # end

  # def signup_member(member)
  #   _post("/api/member")
  #     .send(member)

  # end

  # def login_member(auth)
  #   _post("/api/member/login")
  #     .send(auth)

  # end

  # def forgot_password(member)
  #   _post("/api/member/forgot-password")
  #     .send(member)

  # end

  # def reset_password(params)
  #   _post("/api/member/password")
  #     .send(params)

  # end

  # def vote_on_story (data)
  #    story_id = data.story_id
  #   delete data.story_id

  #     .post(global.sketches.config["sketches-host"] + "/api/stories/" + story_id + "/votes")
  #     .send(data)

  # end

  # def fetch_vote_on_story (data)
  #    story_id = data.story_id
  #   delete data.story_id

  #     .get(global.sketches.config["sketches-host"] + "/api/stories/" + story_id + "/votes")
  #     .send(data)

  # end

  private

  def _get(*args)
    response = conn.get(*args)
    body = JSON.parse(response.body)

    case body
    when Array
      body.map { |i| keywordize(i) }
    when Object
      keywordize body
    end
  end

  def keywordize(obj)
    obj.deep_transform_keys { |k| k.gsub('-', '_').to_sym }
  end
end
