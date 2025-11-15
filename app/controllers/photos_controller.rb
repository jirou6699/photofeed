class PhotosController < ApplicationController
  before_action :require_login, only: [ :index ]

  def index; end

  private

  def require_login
    return if logged_in?
    redirect_to root_path, alert: 'Please log in to access photos'
  end
end
