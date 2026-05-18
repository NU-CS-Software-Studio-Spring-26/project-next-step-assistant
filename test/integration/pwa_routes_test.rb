require "test_helper"

class PwaRoutesTest < ActionDispatch::IntegrationTest
  test "manifest returns json" do
    get pwa_manifest_path(format: :json)
    assert_response :success
    assert_equal "application/json", response.media_type
    body = JSON.parse(response.body)
    assert_equal "Next Step Assistant", body["name"]
  end

  test "service worker is served" do
    get pwa_service_worker_path
    assert_response :success
    assert_match(/serviceWorker|skipWaiting/i, response.body)
  end
end
