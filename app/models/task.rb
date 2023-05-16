class Task < ApplicationRecord
  validates :name, format: { without: /\r|\n/, message: "Line breaks are not allowed" }, presence: true
  has_many :assigned_tasks
end
