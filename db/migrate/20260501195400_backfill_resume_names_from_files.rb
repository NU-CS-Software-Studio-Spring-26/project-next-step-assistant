class BackfillResumeNamesFromFiles < ActiveRecord::Migration[8.1]
  class Resume < ApplicationRecord
    self.table_name = "resumes"
    has_one_attached :file
  end

  def up
    Resume.where(name: "Resume").find_each do |resume|
      next unless resume.file.attached?

      inferred_name = resume.file.filename.base.to_s
      next if inferred_name.blank?

      resume.update_columns(name: inferred_name, updated_at: Time.current)
    end
  end

  def down
    # Irreversible data migration.
  end
end
