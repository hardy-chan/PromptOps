class AnalyzeCodeJob < ApplicationJob
  queue_as :default

  def perform(code_analysis_id, code_snippet)
    AiAnalyzerService.new(code_analysis_id, code_snippet).call
  end
end
