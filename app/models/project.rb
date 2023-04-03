class Project < ApplicationRecord
  belongs_to :client
  has_many :memberships
  has_many :users, through: :memberships
  has_many :assigned_tasks
end
