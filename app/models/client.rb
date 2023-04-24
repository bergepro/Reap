class Client < ApplicationRecord
    validates :name, presence: true, length: {minimum:2, maximum:30}      
    validates :description,presence: true, length: {minimum:2, maximum:100}

    has_many :projects
end
