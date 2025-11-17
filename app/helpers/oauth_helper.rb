module OauthHelper
  def oauth_authorize_url
    config = Rails.application.config.x.oauth

    uri = URI(config.authorize_url)
    params = {
      response_type: config.response_type,
      client_id:     config.client_id,
      redirect_uri:  config.redirect_uri,
      scope:         config.scope
    }

    uri.query = URI.encode_www_form(params)
    uri.to_s
  end
end
