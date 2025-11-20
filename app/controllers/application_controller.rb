class ApplicationController < ActionController::Base
  require 'net/http'
  include SessionsHelper

  private

  def require_login
    return if logged_in?
    redirect_to root_path, alert: t('flash.auth.require_login')
  end
end
