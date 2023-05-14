class AddGroupByToProjectReports < ActiveRecord::Migration[7.0]
  def change
    add_column :project_reports, :group_by, :string
  end
end
