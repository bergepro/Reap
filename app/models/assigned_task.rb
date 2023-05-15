class AssignedTask < ApplicationRecord
  belongs_to :project
  belongs_to :task

  has_many :time_regs, dependent: :destroy
  def name
    task.name
  end
end
