Rails.application.config.x.oauth.tap do |config|
  config.authorize_url = ENV['OAUTH_AUTHORIZE_URL']
  config.response_type = ENV['OAUTH_RESPONSE_TYPE']
  config.client_id     = ENV['OAUTH_CLIENT_ID']
  config.redirect_uri  = ENV['OAUTH_REDIRECT_URI']
  config.scope         = ENV['OAUTH_SCOPE']
end
