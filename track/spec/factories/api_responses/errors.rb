FactoryBot.define do
  factory :api_error_response, class: Hash do
    code { "INVALID_TOKEN" }
    message    { "Token is invalid" }
    detail { "detail" }

    initialize_with { attributes }
  end

  factory :api_errors_response, class: Hash do
    transient do
      errors_count { 1 }
    end

    errors do
      Array.new(errors_count) { build(:api_error_response) }
    end

    initialize_with { attributes }
  end
end
