class Resume < ApplicationRecord
  NAME_MAX_LENGTH = 200
  FILE_MAX_SIZE = 5.megabytes
  PDF_MAGIC_BYTES = "%PDF-".b
  PDF_CONTENT_TYPES = %w[application/pdf application/x-pdf].freeze

  belongs_to :user
  has_many :jobs, dependent: :nullify

  has_one_attached :file, dependent: :purge_later

  validates :name, presence: true, length: { maximum: NAME_MAX_LENGTH }

  before_validation :upload_attached_file_for_validation, if: -> { file.attached? }

  validate :file_must_be_attached, on: :create
  validate :file_must_be_pdf
  validate :file_size_within_limit

  def display_name
    if file.attached?
      filename = file.filename.to_s.presence || "file"
      "#{name} — #{filename} (#{created_at.strftime('%b %d')})"
    else
      name.presence || "Resume #{id}"
    end
  end

  private

  def upload_attached_file_for_validation
    blob = file.blob
    return if blob.blank? || blob.service.exist?(blob.key)

    attachment_changes["file"]&.upload
  end

  def file_must_be_attached
    errors.add(:file, "must be uploaded") unless file.attached?
  end

  def file_must_be_pdf
    return unless file.attached?

    errors.add(:file, "must be a PDF file") unless pdf_file?(file)
  end

  def file_size_within_limit
    return unless file.attached?

    size = file.blob&.byte_size.to_i
    return if size <= FILE_MAX_SIZE

    errors.add(:file, "must be #{FILE_MAX_SIZE / 1.megabyte} MB or smaller")
  end

  def pdf_file?(attachment)
    blob = attachment.blob
    return false if blob.blank?

    filename = blob.filename.to_s
    return false unless filename.match?(/\.pdf\z/i)

    declared_type = blob.content_type.to_s
    return false unless PDF_CONTENT_TYPES.include?(declared_type)

    sample = attachment.download
    sample = sample.byteslice(0, 4096) if sample.bytesize > 4096
    return false if sample.blank?
    return false unless sample.b.start_with?(PDF_MAGIC_BYTES)

    detected_type = Marcel::MimeType.for(sample, name: filename, declared_type: declared_type)
    detected_type.in?(%w[application/pdf application/octet-stream])
  rescue StandardError
    false
  end
end
