class ApplicationController < ActionController::Base
  require 'net/http'
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include SessionsHelper

  private

  def require_login
    return if logged_in?
    redirect_to root_path, alert: 'Please log in to access this page'
  end
end
