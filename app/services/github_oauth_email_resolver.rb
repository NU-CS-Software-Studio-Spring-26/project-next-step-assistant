class GithubOauthEmailResolver
  def self.call(auth)
    new(auth).resolve
  end

  def initialize(auth)
    @auth = auth
  end

  def resolve
    from_info || from_all_emails || from_raw_info
  end

  private

  attr_reader :auth

  def from_info
    normalize_email(auth.info.email)
  end

  def from_all_emails
    emails = auth.extra&.all_emails
    return if emails.blank?

    primary = emails.find { |entry| entry["primary"] && entry["verified"] }
    return normalize_email(primary["email"]) if primary

    verified = emails.find { |entry| entry["verified"] }
    normalize_email(verified&.dig("email"))
  end

  def from_raw_info
    normalize_email(auth.extra&.raw_info&.dig("email"))
  end

  def normalize_email(value)
    value.to_s.strip.downcase.presence
  end
end
