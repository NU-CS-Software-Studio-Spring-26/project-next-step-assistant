class CreateJobs < ActiveRecord::Migration[8.1]
  def change
    create_table :jobs do |t|
      t.string :title
      t.string :organization_name
      t.date :deadline
      t.date :start_date
      t.text :description
      t.string :status

      t.timestamps
    end
  end
end
