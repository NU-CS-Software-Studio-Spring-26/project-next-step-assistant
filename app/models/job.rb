class Job < ApplicationRecord
  TITLE_MAX_LENGTH = 200
  ORGANIZATION_NAME_MAX_LENGTH = 200
  DESCRIPTION_MAX_LENGTH = 5_000

  # simple bad word filter list
  BAD_WORDS = %w[
    fuck
    shit
    bitch
    asshole
    bastard
  ].freeze

  belongs_to :user
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
  # prevent duplicate job titles for the same user
  validates :title, presence: true, length: { maximum: TITLE_MAX_LENGTH }, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :organization_name, presence: true, length: { maximum: ORGANIZATION_NAME_MAX_LENGTH }
  validates :status, presence: true
  validates :description, length: { maximum: DESCRIPTION_MAX_LENGTH }, allow_blank: true
  # require jobs to have deadlines
  validates :deadline, presence: true
  # custom validation for inappropriate language
  validate :no_bad_words

  private

  # Added: checks text fields for inappropriate language
  def no_bad_words
    text = [
      title,
      organization_name,
      description
    ].compact.join(" ").downcase
    return unless BAD_WORDS.any? { |word| text.include?(word) }
    errors.add(:base, "Please remove inappropriate language.")
  end
end
