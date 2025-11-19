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
    config = Rails.application.config.x.oauth
    uri = URI.parse(config.token_url)
    Net::HTTP.post_form(uri, build_token_params)
  end

  def build_token_params
    config = Rails.application.config.x.oauth
    {
      grant_type:    config.grant_type,
      code:          params[:code],
      redirect_uri:  config.redirect_uri,
      client_id:     config.client_id,
      client_secret: config.client_secret
    }
  end

  def store_access_token(response)
    access_token = JSON.parse(response.body)["access_token"]
    raise "Access token not found in response" if access_token.blank?
    session[:oauth_access_token] = access_token
  end
end
