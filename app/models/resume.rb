class Resume < ApplicationRecord
  NAME_MAX_LENGTH = 200

  belongs_to :user, optional: true
  has_many :jobs, dependent: :nullify

  has_one_attached :file, dependent: :purge_later

  validates :name, presence: true, length: { maximum: NAME_MAX_LENGTH }

  validate :file_must_be_attached, on: :create
  validate :file_must_be_pdf

  def display_name
    if file.attached?
      filename = file.filename.to_s.presence || "file"
      "#{name} — #{filename} (#{created_at.strftime('%b %d')})"
    else
      name.presence || "Resume #{id}"
    end
  end

  private

  def file_must_be_attached
    errors.add(:file, "must be uploaded") unless file.attached?
  end

  def file_must_be_pdf
    return unless file.attached?

    type = file.blob&.content_type
    return if type == "application/pdf"

    errors.add(:file, "must be a PDF")
  end
end
