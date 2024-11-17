module Web3
  module Responses
    module Authentications
      class Nonce < Web3::Base
        PATH = Web3::Url::NONCE_GET

        # def initialize(delivery_id:, company_id:, params:)
        #   @delivery_id = delivery_id
        #   @company_id = company_id
        #   @params = params
        # end

        def path
          PATH
        end

        def fetch
          response = get(path)
          case response
          when Net::HTTPCreated then
            Web3::Response::Authentications::Nonce.new(
              WevoxEngagementSurvey::Response::Base::HTTP_CREATED, response
            )
          when Net::HTTPBadRequest then
            Web3::Responses::Authentications::Nonce.new(
              WevoxEngagementSurvey::Response::Base::HTTP_BAD_REQUEST, response
            )
          when Net::HTTPInternalServerError
            WevoxEngagementSurvey::Response::ScoreSummary::Create.new(
              WevoxEngagementSurvey::Response::Base::HTTP_INTERNAL_SERVER_ERROR, response
            )
          else
            WevoxEngagementSurvey::Response::ScoreSummary::Create.new(
              WevoxEngagementSurvey::Response::Base::UNEXPECTED_ERROR, nil
            )
          end
        end
      end
    end
  end
end
