class SessionsController < ApplicationController
  before_action :build_user

  def new; end

  def create
    return render :new if @user.invalid?
    if user = User.find_for_authentication_with(user_params)
      sign_in(user)
      persist_session_for(user)
      redirect_to photos_path, notice: 'Logged in successfully'
    else
      @user.errors.add(:base, 'emailかパスワードが正しくありません')
      render :new
    end
  rescue StandardError => e
    logger.error "Session creation failed: #{e.message}"
    redirect_to root_path, alert: 'Please try again.'
  end

  def destroy
    return if !logged_in?
    sign_out
    redirect_to root_path, notice: 'Logged out successfully'
  rescue StandardError => e
    logger.error "Session destruction failed: #{e.message}"
    redirect_to root_path, alert: 'Please try again.'
  end

  private

  def user_params
    params.permit(:email, :password)
  end

  def build_user
    @user = User.new(user_params) if user_params.present?
    @user ||= User.new
  end
end
