class Project < ApplicationRecord
  NAME_MAX_LENGTH = 200
  SKILLS_MAX_LENGTH = 255
  GITHUB_LINK_MAX_LENGTH = 2_048
  DESCRIPTION_MAX_LENGTH = 5_000

  # Added: list of blocked inappropriate words.
  BAD_WORDS = %w[
    fuck
    shit
    bitch
    asshole
    bastard
  ].freeze

  belongs_to :user, optional: true

  validates :name, presence: true, length: { maximum: NAME_MAX_LENGTH }

  validates :skills,
            length: { maximum: SKILLS_MAX_LENGTH },
            allow_blank: true

  validates :description,
            length: { maximum: DESCRIPTION_MAX_LENGTH },
            allow_blank: true

  validates :github_link,
            length: { maximum: GITHUB_LINK_MAX_LENGTH },
            allow_blank: true

  validates :github_link,
            format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) },
            allow_blank: true

  # Added: prevent duplicate project names for the same user.
  validates :name,
            uniqueness: {
              scope: :user_id,
              case_sensitive: false
            }

  # Added: checks project text fields for inappropriate language.
  validate :no_bad_words

  private

  # Added: custom validation for inappropriate language.
  def no_bad_words
    text = [
      name,
      skills,
      description,
      github_link
    ].compact.join(" ").downcase

    return unless BAD_WORDS.any? { |word| text.include?(word) }

    errors.add(:base, "Please remove inappropriate language.")
  end
end