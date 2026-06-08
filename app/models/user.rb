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

  after_create :mark_password_as_set, unless: :github_connected?

  def self.from_omniauth(auth, current_user: nil)
    provider = auth.provider.to_s
    uid = auth.uid.to_s
    email = GithubOauthEmailResolver.call(auth)

    existing_github_user = find_by(provider: provider, uid: uid)
    if existing_github_user
      if current_user && current_user.id != existing_github_user.id
        return current_user.tap { |u| u.errors.add(:base, "This GitHub account is already linked to another user.") }
      end

      return existing_github_user
    end

    if current_user
      return link_github_to_user(current_user, provider:, uid:, email:)
    end

    if email.blank?
      return new.tap do |u|
        u.errors.add(
          :email,
          "was not provided by GitHub. Add a verified email in your GitHub account settings or sign in with email and password."
        )
      end
    end

    existing = find_by(email: email)
    if existing
      if existing.provider.present? && existing.provider != provider
        existing.errors.add(:base, "is already linked to another sign-in method.")
        return existing
      end

      if existing.github_connected? && existing.uid != uid
        existing.errors.add(:base, "is already linked to a different GitHub account.")
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

  def self.link_github_to_user(user, provider:, uid:, email:)
    other = find_by(provider: provider, uid: uid)
    if other && other.id != user.id
      user.errors.add(:base, "This GitHub account is already linked to another user.")
      return user
    end

    if user.github_connected? && user.uid != uid
      user.errors.add(:base, "Your account is already linked to a different GitHub account.")
      return user
    end

    if user.provider.present? && user.provider != provider
      user.errors.add(:base, "Your account is already linked to another sign-in method.")
      return user
    end

    user.provider = provider
    user.uid = uid
    user.save
    user
  end

  def github_connected?
    provider == "github" && uid.present?
  end

  def needs_password_setup?
    password_set_at.nil?
  end

  def mark_password_as_set!
    update!(password_set_at: Time.current)
  end

  def self.oauth_password
    # Meets password_complexity for Devise create; not used for GitHub sign-in afterward.
    "#{SecureRandom.alphanumeric(16)}A1!"
  end

  # Generates a calendar feed token lazily the first time the user views the
  # subscribe page. Tokens are high-entropy and URL-safe.
  def ensure_calendar_token!
    update!(calendar_token: SecureRandom.urlsafe_base64(24)) if calendar_token.blank?
    calendar_token
  end

  def regenerate_calendar_token!
    update!(calendar_token: SecureRandom.urlsafe_base64(24))
  end

  private

  def mark_password_as_set
    update_column(:password_set_at, Time.current)
  end

  def password_complexity
    return if password.blank?

    errors.add(:password, "must include at least one uppercase letter") unless password.match?(/[A-Z]/)
    errors.add(:password, "must include at least one lowercase letter") unless password.match?(/[a-z]/)
    errors.add(:password, "must include at least one number") unless password.match?(/\d/)
    errors.add(:password, "must include at least one special character") unless password.match?(/[^A-Za-z0-9]/)
  end
end
