class Resume < ApplicationRecord
  belongs_to :job

  has_one_attached :file, dependent: :purge_later

  validate :file_must_be_attached
  validate :file_must_be_pdf

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
