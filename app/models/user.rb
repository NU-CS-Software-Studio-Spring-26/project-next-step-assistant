class User < ApplicationRecord
  EMAIL_MAX_LENGTH = 255
  PASSWORD_MAX_LENGTH = 72

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, length: { maximum: EMAIL_MAX_LENGTH }, allow_blank: true
  validates :password, length: { maximum: PASSWORD_MAX_LENGTH }, allow_blank: true

  has_many :jobs, dependent: :destroy
  has_many :resumes, dependent: :destroy
  has_many :projects, dependent: :destroy
end
