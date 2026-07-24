class AiAnalyzerService
  OPENROUTER_URL = "https://openrouter.ai"

  def initialize(code_analysis_id, code_snippet)
    @analysis = CodeAnalysis.find(code_analysis_id)
    @code_snippet = code_snippet
    @api_key = ENV["OPENROUTER_API_KEY"]
  end

  def call
    return unless @analysis.status == "pending"

    @analysis.update!(status: "processing")

    response = send_ai_request
    if response.success?
      process_success(response.body)
    else
      process_failure(response.body)
    end
  rescue => e
    @analysis.update!(status: "failed", review_payload: { error: e.message })
  end

  private

  def send_ai_request
    Faraday.post(OPENROUTER_URL) do |req|
      req.headers["Authorization"] = "Bearer #{@api_key}"
      req.headers["Content-Type"] = "application/json"
      req.body = payload.to_json
    end
  end

  def payload
    {
      model: "meta-llama/llama-3-8b-instruct:free", # Using a free model for setup ease
      response_format: { type: "json_object" },      # Forces JSON output
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: "Analyze this code:\n\n#{@code_snippet}" }
      ]
    }
  end

  def system_prompt
    "You are an expert code reviewer. Analyze the provided code snippet. " \
    "Return exactly a JSON object with two keys: " \
    "'score' (an integer from 0-100 indicating quality) and " \
    "'feedback' (an array of strings listing bugs, improvements, or compliments)."
  end

  def process_success(response_body)
    parsed_json = JSON.parse(response_body)
    ai_content = JSON.parse(parsed_json.dig("choices", 0, "message", "content"))

    @analysis.update!(
      status: "completed",
      code_quality_score: ai_content["score"],
      review_payload: { feedback: ai_content["feedback"] }
    )
  end

  def process_failure(response_body)
    @analysis.update!(
      status: "failed",
      review_payload: { error: "API Error", raw_response: response_body }
    )
  end
end
