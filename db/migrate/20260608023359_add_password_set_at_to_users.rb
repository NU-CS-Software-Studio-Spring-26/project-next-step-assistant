class AddPasswordSetAtToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :password_set_at, :datetime
    # Email/password accounts already chose a password at sign-up.
    execute <<~SQL.squish
      UPDATE users
      SET password_set_at = created_at
      WHERE provider IS NULL
    SQL
  end

  def down
    remove_column :users, :password_set_at
  end
end
