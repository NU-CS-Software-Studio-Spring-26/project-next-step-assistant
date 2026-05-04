class Project < ApplicationRecord
  belongs_to :user, optional: true

  validates :name, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 5_000 }, allow_blank: true
  validates :github_link,
            format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) },
            allow_blank: true
end
