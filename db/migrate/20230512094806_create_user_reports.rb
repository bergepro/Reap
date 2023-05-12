class CreateUserReports < ActiveRecord::Migration[7.0]
  def change
    create_table :user_reports do |t|
      t.string :creator
      t.string :timeframe
      t.date :date_start
      t.date :date_end
      t.string :user
      t.text :task_ids, default: [], array: true
      t.text :project_ids, default: [], array: true
      t.string :group_by

      t.timestamps
    end
  end
end
