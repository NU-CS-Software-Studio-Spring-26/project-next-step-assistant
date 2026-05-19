# Calls GPT-4o-mini to suggest portfolio project ideas tailored to the user's
# current job targets. Returns a Result struct that view code branches on for
# graceful degradation when the API key is missing or the call fails.
class AiProjectSuggestionsService
  Result = Struct.new(:state, :suggestions, :message, keyword_init: true)

  MODEL = "gpt-4o-mini".freeze
  MAX_TOKENS = 1200
  MAX_JOBS_IN_PROMPT = 20
  MAX_PROJECTS_IN_PROMPT = 20
  JOB_DESC_TRUNCATE = 200
  PROJECT_DESC_TRUNCATE = 150
  FOCUS_MAX_LENGTH = 200

  def initialize(user, job_ids: nil, focus: nil)
    @user = user
    @job_ids = job_ids.present? ? Array(job_ids).map(&:to_i).reject(&:zero?) : nil
    @focus = focus.to_s.strip.first(FOCUS_MAX_LENGTH)
  end

  def call
    return not_configured unless ENV["OPENAI_API_KEY"].present?
    return no_jobs if selected_jobs.empty?

    response = client.chat(parameters: chat_parameters)
    Result.new(state: :ready, suggestions: parse_suggestions(response), message: nil)
  rescue Faraday::Error, OpenAI::Error, JSON::ParserError => e
    Rails.logger.error("AI project suggestions failed: #{e.class}: #{e.message}")
    Result.new(state: :error, suggestions: [], message: "AI service is unavailable right now. Please try again in a moment.")
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

  def parse_suggestions(response)
    content = response.dig("choices", 0, "message", "content").to_s
    parsed = JSON.parse(content)
    raw = parsed.is_a?(Array) ? parsed : parsed["suggestions"]
    Array(raw).first(5)
  end

  def not_configured
    Result.new(
      state: :not_configured,
      suggestions: [],
      message: "AI suggestions are currently offline. The OpenAI API key has not been configured for this environment."
    )
  end

  def no_jobs
    Result.new(
      state: :no_jobs,
      suggestions: [],
      message: "Add at least one job before requesting AI project ideas — the suggestions are tailored to the roles you're targeting."
    )
  end

  def prompt
    <<~PROMPT
      You are a career advisor helping a software engineering candidate build a stronger portfolio.

      Target jobs the candidate is applying to:
      #{jobs_text}

      Existing portfolio projects:
      #{projects_text.presence || "(none yet)"}
      #{focus_clause}
      Suggest exactly 5 portfolio project ideas that would meaningfully strengthen these specific applications.
      Avoid suggesting projects the candidate has already built.

      Return your response as a JSON object with a single key "suggestions" whose value is an array of 5 objects.
      Each object must have these keys:
        - name: short project title (max 60 chars)
        - description: 1-2 sentence explanation of what to build
        - skills: comma-separated list of skills/technologies demonstrated
        - reason: 1 sentence on why this strengthens the candidate's applications

      Return JSON only, no markdown.
    PROMPT
  end

  def focus_clause
    return "" if @focus.blank?
    "\nAdditional focus from the candidate: #{@focus}\n"
  end

  def selected_jobs
    @selected_jobs ||= begin
      scope = @user.jobs.limit(MAX_JOBS_IN_PROMPT)
      @job_ids.present? ? scope.where(id: @job_ids) : scope
    end
  end

  def jobs_text
    selected_jobs.map do |job|
      desc = job.description.to_s.truncate(JOB_DESC_TRUNCATE)
      "- #{job.title} at #{job.organization_name}: #{desc}"
    end.join("\n")
  end

  def projects_text
    @user.projects.limit(MAX_PROJECTS_IN_PROMPT).map do |project|
      "- #{project.name} (skills: #{project.skills}): #{project.description.to_s.truncate(PROJECT_DESC_TRUNCATE)}"
    end.join("\n")
  end
end
