# frozen_string_literal: true

require 'active_support/cache'
require 'active_support/cache/redis_cache_store'

PROTECTED_APIS = %w[mail_check].freeze

def find_app_via_path(env)
  app = env['PATH_INFO'].split('/').reject(&:blank?).first
  return if app.blank? || !PROTECTED_APIS.include?(app)

  "CodeWithSense::#{app.camelize}".constantize
rescue NameError
  nil
end

Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new

Rack::Attack.throttle('requests by ip', limit: 60, period: 1.hour) do |req|
  app = find_app_via_path(req.env)
  req.ip if app && req.params['api_key'] != ENV['API_TOKEN']
end

Rack::Attack.throttled_response = lambda do |env|
  match_data = env['rack.attack.match_data']
  now = match_data[:epoch_time]

  headers = {
    'Content-Type' => 'application/json',
    'RateLimit-Remaining' => '0',
    'RateLimit-Limit' => match_data[:limit].to_s,
    'RateLimit-Reset' => (now + (match_data[:period] - now % match_data[:period])).to_s,
    'RateLimit-RetryAfter' => (match_data[:period] - now % match_data[:period]).to_s
  }

  app = find_app_via_path(env)

  data = {}
  data[:error]  = 'This api only serves as a demo and should not be used in production.'
  data[:option] = 'If you do have the API key, please provide one in the URL.'
  data[:help]   = "Please, deploy your own version via: #{app.read_me}" if app
  [429, headers, [data.to_json]]
end
