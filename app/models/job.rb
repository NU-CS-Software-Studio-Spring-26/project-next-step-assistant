class Job < ApplicationRecord
  belongs_to :resume, optional: true
  has_many :resumes, dependent: :destroy
end
