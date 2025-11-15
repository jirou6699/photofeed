class User < ApplicationRecord
  attr_accessor :session_token
  has_secure_password

  validates :email, presence: true

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
