require 'net/http'

class OauthController < ApplicationController
  def callback
    return handle_authorization_failure if params[:code].blank?

    response = request_access_token
    if response.is_a?(Net::HTTPSuccess)
      store_access_token(response)
      redirect_to photos_path, notice: "連携が完了しました"
    else
      handle_authorization_failure(response.body)
    end
  rescue StandardError => e
    Rails.logger.error "OAuth error: #{e.class} - #{e.message}"
    handle_authorization_failure
  end

  private

  def handle_authorization_failure(message = nil)
    Rails.logger.error "Rails logger error: #{message}" if message.present?
    redirect_to photos_path, alert: "再度連携をお願いします"
  end

  def request_access_token
    uri = URI.parse(ENV['OAUTH_TOKEN_URL'])
    Net::HTTP.post_form(uri, build_token_params)
  end

  def build_token_params
    {
      grant_type:    ENV['OAUTH_GRANT_TYPE'],
      code:          params[:code],
      redirect_uri:  ENV['OAUTH_REDIRECT_URI'],
      client_id:     ENV['OAUTH_CLIENT_ID'],
      client_secret: ENV['OAUTH_CLIENT_SECRET']
    }
  end

  def store_access_token(response)
    access_token = JSON.parse(response.body)["access_token"]
    raise "Access token not found in response" if access_token.blank?
    session[:oauth_access_token] = access_token
  end
end
