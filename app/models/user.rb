class User < ApplicationRecord
  EMAIL_MAX_LENGTH = 255
  PASSWORD_MAX_LENGTH = 72
  PASSWORD_MIN_LENGTH = 8
  PASSWORD_REQUIREMENTS_HINT =
    "At least 8 characters with uppercase, lowercase, a number, and a special character."

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, length: { maximum: EMAIL_MAX_LENGTH }, allow_blank: true
  validates :password, length: { maximum: PASSWORD_MAX_LENGTH }, allow_blank: true
  validate :password_complexity, if: -> { password.present? }

  has_many :jobs, dependent: :destroy
  has_many :resumes, dependent: :destroy
  has_many :projects, dependent: :destroy

  private

  def password_complexity
    return if password.blank?

    errors.add(:password, "must include at least one uppercase letter") unless password.match?(/[A-Z]/)
    errors.add(:password, "must include at least one lowercase letter") unless password.match?(/[a-z]/)
    errors.add(:password, "must include at least one number") unless password.match?(/\d/)
    errors.add(:password, "must include at least one special character") unless password.match?(/[^A-Za-z0-9]/)
  end
end
