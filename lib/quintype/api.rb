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
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
  end

  def config
    _get(api_base + '/config')
  end

  private

  def _get(*args)
    response = conn.get(*args)
    JSON.parse(response.body)
      .deep_transform_keys { |k| k.gsub('-', '_').to_sym }
  end
end
