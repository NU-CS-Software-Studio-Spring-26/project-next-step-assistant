class AddSourceToJobs < ActiveRecord::Migration[8.1]
  def change
    add_column :jobs, :source, :string
  end
end
