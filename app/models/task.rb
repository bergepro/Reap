class Task < ApplicationRecord
  validates :name, format: { without: /\r|\n/, message: "Line breaks are not allowed" }
  validates :name, presence: :true
  has_many :assigned_tasks
end
