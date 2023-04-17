class Membership < ApplicationRecord
  has_many :time_regs
  belongs_to :user
  belongs_to :project
end
