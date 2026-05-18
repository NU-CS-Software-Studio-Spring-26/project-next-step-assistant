module ApplicationHelper
  include Pagy::Frontend

  def github_oauth_configured?
    ENV["GITHUB_CLIENT_ID"].present? && ENV["GITHUB_CLIENT_SECRET"].present?
  end
end
