module ChainGate
  module Responses
    module Base
      HTTP_OK = 200
      HTTP_CREATED = 201
      HTTP_ACCEPTED = 202
      HTTP_NO_CONTENT = 204
      HTTP_BAD_REQUEST = 400
      HTTP_UNAUTHORIZED = 401
      HTTP_FORBIDDEN = 403
      HTTP_NOT_FOUND = 404
      HTTP_CONFLICT = 409
      HTTP_UNPROCESSABLE_CONTENT = 422
      HTTP_INTERNAL_SERVER_ERROR = 500
      UNEXPECTED_ERROR_CODE = "ERR-NOT-IMPLEMENTED"
      ERROR_HASH = { errors: { code: UNEXPECTED_ERROR_CODE } }

      def to_sym_json(body: {})
        JSON.parse(body).deep_symbolize_keys
      end
    end
  end
end
