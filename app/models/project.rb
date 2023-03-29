class Project < ApplicationRecord
  belongs_to :client
  has_many :memberships
  has_many :users, through: :memberships
end
