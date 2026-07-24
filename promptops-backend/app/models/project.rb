class Project < ApplicationRecord
  belongs_to :user
  has_many :code_analyses, dependent: :destroy

  validates :name, :language, presence: true
end
