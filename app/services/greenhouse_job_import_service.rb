# Fetches a public Greenhouse board job via the official API and returns
# attributes for pre-filling the New Job form (review-before-save flow).
class GreenhouseJobImportService
  Result = Struct.new(:state, :attributes, :message, keyword_init: true)

  ALLOWED_HOSTS = %w[boards.greenhouse.io job-boards.greenhouse.io].freeze
  API_HOST = "boards-api.greenhouse.io"
  URL_PATTERN = %r{
    \Ahttps://
    (?:boards\.greenhouse\.io|job-boards\.greenhouse\.io)/
    ([^/]+)/jobs/(\d+)(?:/|\?|$)
  }ix
  OPEN_TIMEOUT = 5
  READ_TIMEOUT = 10

  PREFILL_KEYS = %w[title organization_name description source].freeze

  def initialize(url, http: nil)
    @url = url.to_s.strip
    @http = http
  end

  def call
    board_token, job_id = parse_url(@url)
    return invalid_url unless board_token && job_id

    payload = fetch_job_payload(board_token, job_id)
    return not_found if payload.blank?

    attrs = map_attributes(payload, board_token, @url)
    return invalid_response if attrs["title"].blank? || attrs["organization_name"].blank?

    Result.new(state: :ready, attributes: attrs, message: nil)
  rescue JSON::ParserError, Timeout::Error, SocketError, Errno::ECONNREFUSED, Errno::ETIMEDOUT => e
    Rails.logger.error("Greenhouse import failed: #{e.class}: #{e.message}")
    Result.new(state: :error, attributes: {}, message: "Unable to import Greenhouse listing.")
  rescue StandardError => e
    Rails.logger.error("Greenhouse import failed: #{e.class}: #{e.message}")
    Result.new(state: :error, attributes: {}, message: "Unable to import Greenhouse listing.")
  end

  private

  def parse_url(raw)
    uri = URI.parse(raw)
    return [ nil, nil ] unless uri.scheme == "https" && ALLOWED_HOSTS.include?(uri.host)

    match = URL_PATTERN.match(raw)
    return [ nil, nil ] unless match

    [ match[1], match[2] ]
  rescue URI::InvalidURIError
    [ nil, nil ]
  end

  def fetch_job_payload(board_token, job_id)
    if @http
      return @http.call(board_token, job_id)
    end

    job_url = api_url("/boards/#{board_token}/jobs/#{job_id}")
    response = http_get(job_url)
    return nil unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end

  def fetch_board_name(board_token)
    board_url = api_url("/boards/#{board_token}")
    response = http_get(board_url)
    return nil unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)["name"].presence
  rescue JSON::ParserError
    nil
  end

  def http_get(url)
    uri = URI(url)
    return nil unless uri.host == API_HOST

    Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: true,
      open_timeout: OPEN_TIMEOUT,
      read_timeout: READ_TIMEOUT
    ) do |http|
      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/json"
      http.request(request)
    end
  end

  def api_url(path)
    "https://#{API_HOST}/v1#{path}"
  end

  def map_attributes(payload, board_token, listing_url)
    title = payload["title"].to_s.strip.first(Job::TITLE_MAX_LENGTH)
    organization_name = organization_from(payload, board_token)
    description = build_description(payload, listing_url)

    {
      "title" => title,
      "organization_name" => organization_name,
      "description" => description,
      "source" => "Company website"
    }.slice(*PREFILL_KEYS)
  end

  def organization_from(payload, board_token)
    org = payload["company_name"].to_s.strip.presence
    org ||= fetch_board_name(board_token)
    org ||= humanize_board_token(board_token)
    org.first(Job::ORGANIZATION_NAME_MAX_LENGTH)
  end

  def humanize_board_token(token)
    token.to_s.tr("-", " ").titleize
  end

  def build_description(payload, listing_url)
    location = extract_location(payload)
    apply_url = payload["absolute_url"].presence || listing_url
    body = plain_text(payload["content"])

    parts = []
    parts << "Location: #{location}" if location.present?
    parts << "" if location.present?
    parts << "Apply:"
    parts << apply_url.to_s
    parts << ""
    parts << "Job Description:"
    parts << body.presence || "See the Greenhouse listing for full details."

    parts.join("\n").strip.first(Job::DESCRIPTION_MAX_LENGTH)
  end

  def extract_location(payload)
    location = payload["location"]
    case location
    when Hash
      location["name"].presence
    when String
      location.presence
    else
      payload.dig("offices", 0, "name").presence ||
        Array(payload["offices"]).filter_map { |office| office.is_a?(Hash) ? office["name"] : nil }.join(", ").presence
    end
  end

  def plain_text(html)
    text = html.to_s
      .gsub(/<br\s*\/?>/i, "\n")
      .gsub(/<\/p>/i, "\n\n")
      .gsub(/<\/li>/i, "\n")
      .gsub(/<\/h[1-6]>/i, "\n\n")
    Rails::HTML5::FullSanitizer.new.sanitize(text).gsub(/\n{3,}/, "\n\n").strip
  end

  def invalid_url
    Result.new(
      state: :invalid_url,
      attributes: {},
      message: "Enter a valid Greenhouse job URL from boards.greenhouse.io or job-boards.greenhouse.io (for example, https://boards.greenhouse.io/company/jobs/123456)."
    )
  end

  def not_found
    Result.new(
      state: :not_found,
      attributes: {},
      message: "Unable to import Greenhouse listing."
    )
  end

  def invalid_response
    Result.new(
      state: :error,
      attributes: {},
      message: "Unable to import Greenhouse listing."
    )
  end
end
