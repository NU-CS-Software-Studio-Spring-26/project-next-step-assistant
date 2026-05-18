# Compares a job description to the user's project and resume metadata using
# simple local keyword overlap (no external APIs or ML).
class JobMatchService
  Result = Struct.new(
    :state,
    :match_level,
    :overlap_keywords,
    :missing_keywords,
    :job_keyword_count,
    :portfolio_keyword_count,
    :message,
    :selected_resume_overlap,
    keyword_init: true
  )

  STOP_WORDS = %w[
    a an and are as at be been being but by can could did do does for from had has
    have he her hers him his how i if in into is it its just like may me more most
    my no nor not of on or our ours out over own same she should so some such than
    that the their them then there these they this those through to too under up us
    very was we were what when where which while who why will with would you your
    yours about across all also any both each few further here itself only other
    own same than then there until while within without yet role team company work
    job jobs position experience years year month months day days using used use
    help helps helped helping make makes made making take takes took taking
    example sample project projects resume resumes description
  ].freeze

  MIN_KEYWORD_LENGTH = 3
  MAX_JOB_KEYWORDS = 40
  MAX_DISPLAY_KEYWORDS = 20

  HIGH_RATIO = 0.5
  MEDIUM_RATIO = 0.25
  HIGH_OVERLAP_COUNT = 5
  MEDIUM_OVERLAP_COUNT = 3

  def initialize(job, projects: nil, resumes: nil)
    @job = job
    @user = job.user
    @projects = Array(projects || @user&.projects || [])
    @resumes = Array(resumes || @user&.resumes || [])
  end

  def call
    return no_job_description unless @job.description.present?

    portfolio_sources = portfolio_text_sources
    return no_portfolio_data if portfolio_sources.empty?

    job_keywords = extract_keywords(@job.description)
    return no_keywords if job_keywords.empty?

    portfolio_keywords = extract_keywords(*portfolio_sources)
    return no_keywords if portfolio_keywords.empty?

    overlap = (job_keywords & portfolio_keywords).sort
    missing = (job_keywords - portfolio_keywords).sort
    resume_overlap = selected_resume_overlap(job_keywords)

    Result.new(
      state: :ready,
      match_level: score_match_level(overlap.size, job_keywords.size),
      overlap_keywords: overlap.first(MAX_DISPLAY_KEYWORDS),
      missing_keywords: missing.first(MAX_DISPLAY_KEYWORDS),
      job_keyword_count: job_keywords.size,
      portfolio_keyword_count: portfolio_keywords.size,
      message: compatibility_message(overlap.size, job_keywords.size, missing.size),
      selected_resume_overlap: resume_overlap.first(MAX_DISPLAY_KEYWORDS)
    )
  end

  private

  def no_job_description
    Result.new(
      state: :no_job_description,
      message: "Add a job description to see keyword matches against your projects and resumes."
    )
  end

  def no_portfolio_data
    Result.new(
      state: :no_portfolio_data,
      message: "Add projects or resumes to compare skills and keywords with this role."
    )
  end

  def no_keywords
    Result.new(
      state: :no_keywords,
      message: "We could not extract enough distinctive keywords. Try adding more specific skills and technologies in the job description and your portfolio."
    )
  end

  def portfolio_text_sources
    sources = []
    @projects.each do |project|
      parts = [ project.name, project.skills, project.description ]
      sources << parts.join(" ") if parts.any?(&:present?)
    end
    @resumes.each do |resume|
      sources << resume_metadata_text(resume)
    end
    sources.reject(&:blank?)
  end

  def resume_metadata_text(resume)
    parts = [ resume.name ]
    if resume.file.attached?
      filename = resume.file.filename.to_s
      parts << File.basename(filename, File.extname(filename))
    end
    parts.compact.join(" ")
  end

  def selected_resume_overlap(job_keywords)
    return [] unless @job.resume

    resume_keywords = extract_keywords(resume_metadata_text(@job.resume))
    job_keywords & resume_keywords
  end

  def extract_keywords(*texts)
    raw = texts.flatten.compact.join(" ")
    return [] if raw.blank?

    tokens = tokenize(raw)
    keywords = tokens
      .map { |token| normalize_token(token) }
      .compact
      .reject { |token| stop_word?(token) }
      .uniq

    keywords.first(MAX_JOB_KEYWORDS)
  end

  def tokenize(text)
    normalized = text.to_s.downcase
    normalized = normalized.gsub(/[^\p{Alnum}\s\-+#.]/u, " ")
    normalized.split(/[\s,;|\/]+/).flat_map { |piece| piece.split(/[-.]/) }
  end

  def normalize_token(token)
    cleaned = token.to_s.strip
    return nil if cleaned.length < MIN_KEYWORD_LENGTH
    return nil if cleaned.match?(/\A\d+\z/)

    cleaned
  end

  def stop_word?(token)
    STOP_WORDS.include?(token)
  end

  def score_match_level(overlap_count, job_count)
    ratio = overlap_count.to_f / job_count

    if ratio >= HIGH_RATIO || (overlap_count >= HIGH_OVERLAP_COUNT && ratio >= MEDIUM_RATIO)
      :high
    elsif ratio >= MEDIUM_RATIO || overlap_count >= MEDIUM_OVERLAP_COUNT
      :medium
    else
      :low
    end
  end

  def compatibility_message(overlap_count, job_count, missing_count)
    ratio = (overlap_count.to_f / job_count * 100).round
    if overlap_count.zero?
      "No keyword overlap yet — your portfolio may need more terms that appear in this job posting."
    elsif missing_count.zero?
      "Strong alignment: #{overlap_count} of #{job_count} job keywords (#{ratio}%) appear in your projects or resumes."
    else
      "#{overlap_count} of #{job_count} job keywords (#{ratio}%) match your portfolio; #{missing_count} may be worth highlighting."
    end
  end
end
