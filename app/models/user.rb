class User < ApplicationRecord
  attr_accessor :session_token
  has_secure_password

  validates :email, presence: true

  def self.find_for_authentication_with(params)
    authenticate_by(email: params[:email], password: params[:password])
  end

  def session_token
    @session_token ||= SecureRandom.urlsafe_base64
  end

  def update_session_digest!
    update!(session_digest: BCrypt::Password.create(session_token))
  end

  def authenticated?(token)
    BCrypt::Password.new(session_digest).is_password?(token)
  end
end
