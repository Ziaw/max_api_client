# frozen_string_literal: true

module MaxApiClient
  # Shared HTTP helper for raw API groups.
  class BaseApi
    HTTP_METHODS = %i[get post put patch delete].freeze

    def initialize(client)
      @client = client
    end

    HTTP_METHODS.each do |name|
      define_method(name) do |path, query: nil, body: nil, path_params: nil, open_timeout: nil, read_timeout: nil|
        call_api(name, path, query:, body:, path_params:, open_timeout:, read_timeout:)
      end
    end

    private

    attr_reader :client

    def call_api(http_method, path, query: nil, body: nil, path_params: nil, open_timeout: nil, read_timeout: nil)
      result = client.call(
        method: http_method,
        path:,
        query:,
        body:,
        path_params:,
        open_timeout:,
        read_timeout:
      )
      raise ApiError.new(result[:status], result[:data]) unless result[:status] == 200

      result[:data]
    end

    def compact_nil(hash)
      hash.compact
    end
  end
end
