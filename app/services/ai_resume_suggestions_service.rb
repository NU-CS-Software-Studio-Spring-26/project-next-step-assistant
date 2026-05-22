require "pdf-reader"
require "stringio"

# Calls GPT-4o-mini with the job description plus the extracted text of the
# selected resume PDF, and returns 5 actionable suggestions for tailoring the
# resume to that specific role. Returns a Result struct so views can branch
# on graceful-degradation states.
class AiResumeSuggestionsService
  Result = Struct.new(:state, :improvements, :message, keyword_init: true)

  MODEL = "gpt-4o-mini".freeze
  MAX_TOKENS = 1000
  MAX_RESUME_CHARS = 8000
  MAX_JOB_DESC_CHARS = 4000
  MIN_EXTRACTED_CHARS = 100

  def initialize(job)
    @job = job
    @resume = job.resume
  end

  def call
    return not_configured unless ENV["OPENAI_API_KEY"].present?
    return no_job_description if @job.description.blank?
    return no_resume unless @resume&.file&.attached?

    resume_text = extract_resume_text
    return resume_unreadable if resume_text.length < MIN_EXTRACTED_CHARS

    response = client.chat(parameters: chat_parameters(resume_text))
    Result.new(state: :ready, improvements: parse_improvements(response), message: nil)
  rescue Faraday::Error, OpenAI::Error, JSON::ParserError => e
    Rails.logger.error("AI resume suggestions failed: #{e.class}: #{e.message}")
    Result.new(state: :error, improvements: [], message: "AI service is unavailable right now. Please try again in a moment.")
  end

  private

  def client
    @client ||= OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  def extract_resume_text
    @resume.file.open do |tempfile|
      reader = PDF::Reader.new(tempfile)
      reader.pages.map(&:text).join("\n")
    end.to_s.strip.first(MAX_RESUME_CHARS)
  rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError => e
    Rails.logger.warn("Could not parse resume PDF for job=#{@job.id}: #{e.class}: #{e.message}")
    ""
  end

  def chat_parameters(resume_text)
    {
      model: MODEL,
      messages: [ { role: "user", content: prompt(resume_text) } ],
      max_tokens: MAX_TOKENS,
      response_format: { type: "json_object" }
    }
  end

  def parse_improvements(response)
    content = response.dig("choices", 0, "message", "content").to_s
    parsed = JSON.parse(content)
    raw = parsed.is_a?(Array) ? parsed : parsed["improvements"]
    Array(raw).map { |item| normalize_improvement(item) }.compact.first(5)
  end

  # Accepts hashes in either the "edit" or "big_picture" shape, or a legacy
  # plain string (treated as an edit). Returns a uniform hash with a "type" key
  # and the fields the view expects, or nil if the item is unusable.
  def normalize_improvement(item)
    if item.is_a?(Hash)
      normalize_hash_improvement(item)
    else
      text = item.to_s.strip
      return nil if text.blank?
      { "type" => "edit", "original" => "", "suggested" => text, "reason" => "" }
    end
  end

  def normalize_hash_improvement(item)
    type = item["type"].to_s.strip.downcase
    reason = item["reason"].to_s.strip

    if type == "big_picture"
      suggestion = item["suggestion"].to_s.strip
      return nil if suggestion.blank?
      { "type" => "big_picture", "suggestion" => suggestion, "reason" => reason }
    else
      suggested = item["suggested"].to_s.strip
      return nil if suggested.blank?
      {
        "type" => "edit",
        "original" => item["original"].to_s.strip,
        "suggested" => suggested,
        "reason" => reason
      }
    end
  end

  def prompt(resume_text)
    <<~PROMPT
      You are a career advisor helping a candidate tailor their resume for a specific job. Return a MIX of concrete text edits and big-picture strategic advice.

      Job title: #{@job.title}
      Organization: #{@job.organization_name}
      Job description:
      #{@job.description.to_s.first(MAX_JOB_DESC_CHARS)}

      Current resume content (extracted from PDF):
      #{resume_text}

      Produce exactly 5 recommendations. Aim for roughly 3 specific text edits and 2 big-picture strategic suggestions — adjust the ratio if it makes the advice more useful.

      For each SPECIFIC TEXT EDIT, return an object with:
        - "type": "edit"
        - "original": the EXACT phrase, bullet, or section from the resume to change. If suggesting a brand-new bullet that doesn't replace anything, use the literal string "(new addition)".
        - "suggested": the exact replacement text, written as a finished resume bullet or sentence (not a description of what to write).
        - "reason": one sentence explaining how this change strengthens the resume for THIS specific job.

      For each BIG-PICTURE STRATEGIC SUGGESTION (e.g. reorder sections, add/remove a category like projects or skills summary, shift emphasis, consolidate, change framing), return an object with:
        - "type": "big_picture"
        - "suggestion": the strategic recommendation, written as actionable advice.
        - "reason": one sentence explaining why this matters for THIS specific job.

      Avoid generic platitudes like "use stronger action verbs" or "quantify your impact" — every recommendation must be tied to THIS resume and THIS job.

      Return your response as a JSON object:
      {
        "improvements": [
          { "type": "edit", "original": "...", "suggested": "...", "reason": "..." },
          { "type": "big_picture", "suggestion": "...", "reason": "..." },
          ...
        ]
      }

      Return JSON only, no markdown.
    PROMPT
  end

  def not_configured
    Result.new(
      state: :not_configured,
      improvements: [],
      message: "AI suggestions are currently offline. The OpenAI API key has not been configured for this environment."
    )
  end

  def no_job_description
    Result.new(
      state: :no_job_description,
      improvements: [],
      message: "Add a job description so the AI knows what role you're tailoring the resume for."
    )
  end

  def no_resume
    Result.new(
      state: :no_resume,
      improvements: [],
      message: "Assign a resume to this job — the AI needs the resume content to suggest improvements."
    )
  end

  def resume_unreadable
    Result.new(
      state: :resume_unreadable,
      improvements: [],
      message: "We couldn't extract enough text from this PDF. Try re-exporting the resume from your editor (Word, Google Docs, etc.) — scanned PDFs often have no embedded text."
    )
  end
end
