module OauthHelper
  def oauth_authorize_url
    uri = URI(ENV['OAUTH_AUTHORIZE_URL'])
    params = {
      response_type: ENV['OAUTH_RESPONSE_TYPE'],
      client_id:     ENV['OAUTH_CLIENT_ID'],
      redirect_uri:  ENV['OAUTH_REDIRECT_URI'],
      scope:         ENV['OAUTH_SCOPE']
    }

    uri.query = URI.encode_www_form(params)
    uri.to_s
  end
end
