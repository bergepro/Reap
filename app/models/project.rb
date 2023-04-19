class Project < ApplicationRecord
  validates :name, presence: true, length: {minimum:2, maximum:30}      
  validates :description,presence: true, length: {minimum:2, maximum:100}

  belongs_to :client
  has_many :memberships
  has_many :users, through: :memberships
  has_many :time_regs, through: :memberships
  has_many :assigned_tasks
end
