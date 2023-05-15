class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :memberships, dependent: :destroy
  has_many :projects, through: :memberships
  has_many :time_regs, through: :memberships

  def name
    "#{first_name} #{last_name}"
  end
  
  def user_id
    id
  end
end
