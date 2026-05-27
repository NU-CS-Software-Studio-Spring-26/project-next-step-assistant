# Calls GPT-4o-mini with a pasted job posting and returns structured fields
# (title, organization, dates, description, source) for pre-filling the New
# Job form. Returns a Result struct so views can branch on state.
class JobImportService
  Result = Struct.new(:state, :attributes, :message, keyword_init: true)

  MODEL = "gpt-4o-mini".freeze
  MAX_TOKENS = 800
  MIN_INPUT_CHARS = 50
  MAX_INPUT_CHARS = 12_000

  EXTRACTED_KEYS = %w[title organization_name deadline start_date description source].freeze

  def initialize(text)
    @text = text.to_s.strip.first(MAX_INPUT_CHARS)
  end

  def call
    return not_configured unless ENV["OPENAI_API_KEY"].present?
    return too_short if @text.length < MIN_INPUT_CHARS

    response = client.chat(parameters: chat_parameters)
    attrs = parse_attributes(response)
    Result.new(state: :ready, attributes: attrs, message: nil)
  rescue Faraday::Error, OpenAI::Error, JSON::ParserError => e
    Rails.logger.error("Job import failed: #{e.class}: #{e.message}")
    Result.new(state: :error, attributes: {}, message: "AI service is unavailable right now. Please try again in a moment.")
  end

  private

  def client
    @client ||= OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  def chat_parameters
    {
      model: MODEL,
      messages: [ { role: "user", content: prompt } ],
      max_tokens: MAX_TOKENS,
      response_format: { type: "json_object" }
    }
  end

  def parse_attributes(response)
    content = response.dig("choices", 0, "message", "content").to_s
    parsed = JSON.parse(content)
    EXTRACTED_KEYS.each_with_object({}) do |key, acc|
      value = parsed[key]
      acc[key] = sanitize_value(key, value) if value.present?
    end
  end

  def sanitize_value(key, value)
    case key
    when "deadline", "start_date"
      Date.iso8601(value.to_s) rescue nil
    when "source"
      Job::SOURCES.include?(value.to_s) ? value.to_s : nil
    else
      value.to_s.strip.presence
    end
  end

  def prompt
    <<~PROMPT
      You are extracting structured fields from a pasted job posting so the user can pre-fill a job-tracker form. Return JSON only.

      Source text (job posting):
      #{@text}

      Extract these exact fields. If a field is not clearly stated in the text, return null for that field. Do NOT invent values.

      Required JSON shape:
      {
        "title": string|null,              // The job title, e.g. "Software Engineer Intern"
        "organization_name": string|null,  // The hiring company / org
        "deadline": "YYYY-MM-DD"|null,     // Application deadline if explicitly stated
        "start_date": "YYYY-MM-DD"|null,   // Job start date if explicitly stated
        "description": string|null,        // A condensed copy of the job description / responsibilities (max ~1500 chars)
        "source": string|null              // ONE of: #{Job::SOURCES.join(", ")} — only if the posting itself mentions where it was sourced
      }

      Rules:
      - Dates must be ISO 8601 (YYYY-MM-DD). If the posting says "Applications close June 15, 2026" → "2026-06-15".
      - Do not put generic boilerplate ("competitive salary", "equal opportunity employer") into description — keep the meaningful role-specific content.
      - source defaults to null unless the text itself indicates a specific source.
      - Return valid JSON only, no markdown fences.
    PROMPT
  end

  def not_configured
    Result.new(
      state: :not_configured,
      attributes: {},
      message: "AI import is currently offline. The OpenAI API key has not been configured for this environment."
    )
  end

  def too_short
    Result.new(
      state: :too_short,
      attributes: {},
      message: "Paste at least #{MIN_INPUT_CHARS} characters of the job posting so the AI has enough to work with."
    )
  end
end
