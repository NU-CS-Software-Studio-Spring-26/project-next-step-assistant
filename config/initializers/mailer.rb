module MailerConfig
  module_function

  def smtp_settings
    return unless ENV["SMTP_ADDRESS"].present?

    {
      address: ENV["SMTP_ADDRESS"],
      port: ENV.fetch("SMTP_PORT", 587).to_i,
      user_name: ENV["SMTP_USERNAME"],
      password: ENV["SMTP_PASSWORD"],
      authentication: ENV.fetch("SMTP_AUTHENTICATION", "plain").to_sym,
      enable_starttls_auto: ENV.fetch("SMTP_ENABLE_STARTTLS_AUTO", "true") == "true"
    }.compact
  end

  def sendgrid_settings
    return unless ENV["SENDGRID_API_KEY"].present?

    {
      address: "smtp.sendgrid.net",
      port: 587,
      user_name: "apikey",
      password: ENV["SENDGRID_API_KEY"],
      authentication: :plain,
      enable_starttls_auto: true
    }
  end

  def active_smtp_settings
    sendgrid_settings || smtp_settings
  end
end
