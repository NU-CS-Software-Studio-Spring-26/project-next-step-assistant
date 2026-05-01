class Resume < ApplicationRecord
  has_many :jobs, dependent: :nullify

  has_one_attached :file, dependent: :purge_later

  validates :name, presence: true

  validate :file_must_be_attached
  validate :file_must_be_pdf

  def display_name
    if file.attached?
      "#{name} — #{file.filename} (#{created_at.strftime('%b %d')})"
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
