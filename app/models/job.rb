class Job < ApplicationRecord
  TITLE_MAX_LENGTH = 200
  ORGANIZATION_NAME_MAX_LENGTH = 200
  DESCRIPTION_MAX_LENGTH = 5_000

  belongs_to :user, optional: true
  belongs_to :resume, optional: true
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

  validates :title, presence: true, length: { maximum: TITLE_MAX_LENGTH }
  validates :organization_name, presence: true, length: { maximum: ORGANIZATION_NAME_MAX_LENGTH }
  validates :status, presence: true
  validates :description, length: { maximum: DESCRIPTION_MAX_LENGTH }, allow_blank: true
end
