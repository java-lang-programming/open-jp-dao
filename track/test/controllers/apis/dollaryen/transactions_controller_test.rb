require "test_helper"

class Apis::Dollaryen::TransactionsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get apis_dollaryen_transactions_create_url
    assert_response :success
  end
end
