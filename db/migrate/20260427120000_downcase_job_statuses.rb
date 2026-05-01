class DowncaseJobStatuses < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE jobs SET status = LOWER(status) WHERE status IS NOT NULL"
  end

  def down
    # Best-effort restoration to the original capitalized form.
    execute <<~SQL
      UPDATE jobs
      SET status = UPPER(SUBSTR(status, 1, 1)) || SUBSTR(status, 2)
      WHERE status IS NOT NULL
    SQL
  end
end
