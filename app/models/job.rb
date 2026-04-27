class Job < ApplicationRecord
  STATUSES = {
    saved: "saved",
    applied: "applied",
    interviewing: "interviewing",
    offer: "offer",
    accepted: "accepted",
    rejected: "rejected",
    withdrawn: "withdrawn"
  }.freeze

  enum :status, STATUSES, default: :saved

  has_many :resumes, dependent: :destroy

  validates :title, presence: true, length: { maximum: 200 }
  validates :organization_name, presence: true, length: { maximum: 200 }
  validates :status, presence: true
  validates :description, length: { maximum: 5_000 }, allow_blank: true
end
