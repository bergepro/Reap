class TimeReg < ApplicationRecord
  belongs_to :membership
  belongs_to :assigned_task

  validates :notes, presence: true, length: { maximum: 255 }
  validates :minutes, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :membership, presence: true
  validates :assigned_task, presence: true
  validates :assigned_task_id, presence: true

end
