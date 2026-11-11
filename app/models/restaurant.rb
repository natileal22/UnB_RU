class Restaurant < ApplicationRecord
  has_many :accesses, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
end
