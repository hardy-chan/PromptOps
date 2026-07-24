class CodeAnalysis < ApplicationRecord
  belongs_to :project

  validates :status, presence: true, inclusion: { in: %w[pending processing completed failed] }
  validates :code_quality_score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
end
