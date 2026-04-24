class CreateResumes < ActiveRecord::Migration[8.1]
  def change
    create_table :resumes do |t|
      t.references :job, null: false, foreign_key: true
      t.string :file_name

      t.timestamps
    end
  end
end
