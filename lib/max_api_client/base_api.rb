# frozen_string_literal: true

module MaxApiClient
  class BaseApi
    def initialize(client)
      @client = client
    end

    private

    attr_reader :client

    def call_api(http_method, path, query: nil, body: nil, path_params: nil)
      result = client.call(method: http_method, path:, query:, body:, path_params:)
      raise ApiError.new(result[:status], result[:data]) unless result[:status] == 200

      result[:data]
    end

    def _get(path, query: nil, path_params: nil)
      call_api("GET", path, query:, path_params:)
    end

    def _post(path, query: nil, body: nil, path_params: nil)
      call_api("POST", path, query:, body:, path_params:)
    end

    def _put(path, query: nil, body: nil, path_params: nil)
      call_api("PUT", path, query:, body:, path_params:)
    end

    def _patch(path, query: nil, body: nil, path_params: nil)
      call_api("PATCH", path, query:, body:, path_params:)
    end

    def _delete(path, query: nil, body: nil, path_params: nil)
      call_api("DELETE", path, query:, body:, path_params:)
    end
  end
end
