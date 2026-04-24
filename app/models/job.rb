class Job < ApplicationRecord
  has_many :resumes, dependent: :destroy
end
