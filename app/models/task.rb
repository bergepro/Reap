class Task < ApplicationRecord
  validates :notes, format: { without: /\r|\n/, message: "Line breaks are not allowed" }

  has_many :assigned_tasks
end
