require "net/http"

module ChainGate
  class Base
    # CONFIG = APP_CONFIG["web3"]
    # BASE_URL = "http://#{CONFIG['host']}:#{CONFIG['port']}"
    BASE_URL = "http://host.docker.internal:8001"
    HEADERS = { "Content-Type" => "application/json" }

    def get(path, query = "")
      uri, http = initialize_http(path)
      req = Net::HTTP::Get.new(uri.path + query)
      response = nil
      http.read_timeout = nil
      begin
        response = http.request(req)
      rescue StandardError => ex
        throw ex
      end
      response
    end

    def post(params, path)
      uri, http = initialize_http(path)
      begin
        http.post(uri.path, params.to_json, HEADERS)
      rescue StandardError => ex
        logger.error(ex)
        throw ex
      end
    end

    def update(params, path)
      uri, http = initialize_http(path)
      begin
        http.put(uri.path, params.to_json)
      rescue StandardError => ex
        throw ex
      end
    end

    def delete(path)
      uri, http = initialize_http(path)
      begin
        http.delete(uri.path)
      rescue StandardError => ex
        throw ex
      end
    end

    def patch(params, path)
      uri, http = initialize_http(path)
      begin
        http.patch(uri.path, params.to_json)
      rescue StandardError => ex
        throw ex
      end
    end

    private

    def initialize_http(path)
      url = BASE_URL + path
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      return uri, http
    end
  end
end
