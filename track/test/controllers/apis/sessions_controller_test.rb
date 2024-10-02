require "test_helper"

class Apis::SessionsControllerTest < ActionDispatch::IntegrationTest
  # status: :ok, json: { nonce: nonce }
  test "should get nonce" do
    get apis_sessions_nonce_url
    assert_response :ok
  end

  test "should post verify" do
    post apis_sessions_verify_url
    assert_response :created
  end

  test "should post signout" do
    post apis_sessions_signout_url
    assert_response :created
  end
end
