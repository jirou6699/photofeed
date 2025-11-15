module SessionsHelper
  def sign_in(user)
    session[:user_id] = user.id
  end

  def persist_session_for(user)
    user.update_session_digest!
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:session_token] = user.session_token
  end

  def logged_in?
    !current_user.nil?
  end

  private

  def find_user_from_cookies
    return if !(user_id = cookies.encrypted[:user_id])
    user = User.find_by(id: user_id)
    if user && user.authenticated?(cookies[:session_token])
      sign_in(user)
      user
    end
  end

  def current_user
    @current_user ||= find_user_from_cookies
    # debugger
  end
end
