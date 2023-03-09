class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.timestamp :start_date
      t.string :description
      t.string :client

      t.timestamps
    end
  end
end
