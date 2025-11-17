class User < ApplicationRecord
  attr_accessor :session_token
  has_secure_password

  has_many :photos, dependent: :destroy

  validates :email, presence: true

  def self.find_for_authentication_with(params)
    authenticate_by(email: normalize_email(params), password: params[:password])
  end

  def self.normalize_email(params)
    params[:email]&.downcase
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
