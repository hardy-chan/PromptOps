class AiAnalyzerService
  OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"

  def initialize(code_analysis_id, code_snippet)
    @analysis = CodeAnalysis.find(code_analysis_id)
    @code_snippet = code_snippet
    @api_key = ENV["OPENROUTER_API_KEY"].to_s.strip
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
      req.headers["HTTP-Referer"] = "http://localhost:3000"
      req.headers["X-Title"] = "PromptOps Code Reviewer"
      
      # Stringify the payload explicitly to prevent hidden transmission errors
      req.body = payload.to_json
    end
  end

  def payload
    {
      model: "google/gemini-2.5-flash",
      max_tokens: 1000, # Limit the response size
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: "Analyze this code snippet:\n\n#{@code_snippet}" }
      ]
    }
  end

  def system_prompt
    "You are an expert code reviewer. " \
    "Analyze the provided code and return your response in plain JSON. " \
    "Your response must be a single JSON object containing two keys: " \
    "'score' (an integer from 0 to 100) and 'feedback' (an array of strings). " \
    "Do not include any markdown blocks, wrappers, or trailing text. Return raw JSON text only."
  end

  def process_success(response_body)
    parsed_json = JSON.parse(response_body)
    raw_content = parsed_json.dig("choices", 0, "message", "content").to_s.strip
    
    # Defensive sanitization step: checks for and removes any rogue ```json code blocks
    cleaned_content = raw_content.gsub(/```json|```/, "").strip
    ai_data = JSON.parse(cleaned_content)

    @analysis.update!(
      status: "completed",
      code_quality_score: ai_data["score"],
      review_payload: { feedback: ai_data["feedback"] }
    )
  end

  def process_failure(response_body)
    # Safely truncates full HTML documents to prevent database write crashes
    truncated_response = response_body.to_s[0..200]
    @analysis.update!(
      status: "failed",
      review_payload: { error: "API Error Response", details: truncated_response }
    )
  end
end
