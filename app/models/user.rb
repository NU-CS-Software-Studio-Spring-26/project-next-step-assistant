class User < ApplicationRecord
  EMAIL_MAX_LENGTH = 255
  PASSWORD_MAX_LENGTH = 72
  PASSWORD_MIN_LENGTH = 8
  PASSWORD_REQUIREMENTS_HINT =
    "At least 8 characters with uppercase, lowercase, a number, and a special character."

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :github ]

  validates :email, length: { maximum: EMAIL_MAX_LENGTH }, allow_blank: true
  validates :password, length: { maximum: PASSWORD_MAX_LENGTH }, allow_blank: true
  validate :password_complexity, if: -> { password.present? }

  has_many :jobs, dependent: :destroy
  has_many :resumes, dependent: :destroy
  has_many :projects, dependent: :destroy

  def self.from_omniauth(auth)
    provider = auth.provider.to_s
    uid = auth.uid.to_s
    email = auth.info.email&.strip&.downcase

    user = find_by(provider: provider, uid: uid)
    return user if user

    if email.blank?
      return new.tap { |u| u.errors.add(:email, "was not provided by GitHub. Use a public email or sign in with email and password.") }
    end

    existing = find_by(email: email)
    if existing
      if existing.provider.present? && existing.provider != provider
        existing.errors.add(:base, "is already linked to another sign-in method.")
        return existing
      end

      existing.provider = provider
      existing.uid = uid
      existing.save
      return existing
    end

    password = oauth_password
    create(
      email: email,
      provider: provider,
      uid: uid,
      password: password,
      password_confirmation: password
    )
  end

  def self.oauth_password
    # Meets password_complexity for Devise create; not used for GitHub sign-in afterward.
    "#{SecureRandom.alphanumeric(16)}A1!"
  end

  private

  def password_complexity
    return if password.blank?

    errors.add(:password, "must include at least one uppercase letter") unless password.match?(/[A-Z]/)
    errors.add(:password, "must include at least one lowercase letter") unless password.match?(/[a-z]/)
    errors.add(:password, "must include at least one number") unless password.match?(/\d/)
    errors.add(:password, "must include at least one special character") unless password.match?(/[^A-Za-z0-9]/)
  end
end
