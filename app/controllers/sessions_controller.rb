class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    user = User.authenticate_by(email: params[:email], password: params[:password])
    if user && user.valid?
      sign_in(user)
      persist_session_for(user)
      redirect_to root_path, notice: 'Logged in successfully'
    else
      render :new
    end
  rescue StandardError => e
    logger.error "Session creation failed: #{e.message}"
    redirect_to root_path, alert: 'Please try again.'
  end
end
