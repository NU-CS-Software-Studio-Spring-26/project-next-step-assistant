class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :github_link
      t.text :description
      t.string :skills

      t.timestamps
    end
  end
end
