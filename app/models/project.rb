class Project < ApplicationRecord
  NAME_MAX_LENGTH = 200
  SKILLS_MAX_LENGTH = 255
  GITHUB_LINK_MAX_LENGTH = 2_048
  DESCRIPTION_MAX_LENGTH = 5_000

  belongs_to :user, optional: true

  validates :name, presence: true, length: { maximum: NAME_MAX_LENGTH }
  validates :skills, length: { maximum: SKILLS_MAX_LENGTH }, allow_blank: true
  validates :description, length: { maximum: DESCRIPTION_MAX_LENGTH }, allow_blank: true
  validates :github_link, length: { maximum: GITHUB_LINK_MAX_LENGTH }, allow_blank: true
  validates :github_link,
            format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) },
            allow_blank: true
end
