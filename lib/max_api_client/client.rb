# frozen_string_literal: true

module MaxApiClient
  class Client
    DEFAULT_BASE_URL = "https://platform-api.max.ru"

    attr_reader :token, :base_url

    def initialize(token:, base_url: DEFAULT_BASE_URL, adapter: nil, open_timeout: nil, read_timeout: nil)
      @token = token
      @base_url = base_url
      @adapter = adapter
      @open_timeout = open_timeout
      @read_timeout = read_timeout
    end

    def call(method:, path: nil, query: nil, body: nil, path_params: nil, headers: nil, url: nil, raw_body: nil,
             parse_json: true)
      request = {
        method: method.to_s.upcase,
        url: build_url(path:, path_params:, query:, url:),
        path: path,
        path_params: path_params,
        query: query,
        body: body,
        raw_body: raw_body,
        headers: default_headers(headers, body:, raw_body:),
        parse_json: parse_json
      }

      return @adapter.call(request) if @adapter

      perform_request(request)
    end

    private

    def build_url(path:, path_params:, query:, url:)
      uri = if url
              URI(url)
            else
              URI.join(base_url.end_with?("/") ? base_url : "#{base_url}/", expand_path(path.to_s, path_params))
            end

      params = URI.decode_www_form(String(uri.query))
      (query || {}).each do |key, value|
        next if value.nil? || value == false

        params << [key.to_s, value.to_s]
      end
      uri.query = params.empty? ? nil : URI.encode_www_form(params)
      uri
    end

    def expand_path(path, path_params)
      expanded = path.dup
      (path_params || {}).each do |key, value|
        expanded.gsub!("{#{key}}", URI.encode_www_form_component(value.to_s))
      end
      expanded
    end

    def default_headers(headers, body:, raw_body:)
      result = {
        "Authorization" => token.to_s
      }
      result["Content-Type"] = "application/json" if body && raw_body.nil?
      result.merge!(headers || {})
      result
    end

    def perform_request(request)
      uri = request.fetch(:url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = @open_timeout if @open_timeout
      http.read_timeout = @read_timeout if @read_timeout

      req = net_http_request_class(request.fetch(:method)).new(uri)
      request.fetch(:headers).each do |key, value|
        req[key] = value
      end

      if request[:raw_body]
        req.body = request[:raw_body]
      elsif request[:body]
        req.body = JSON.generate(request[:body])
      end

      response = http.request(req)
      body = response.body.to_s
      data = if request[:parse_json] && !body.empty?
               JSON.parse(body)
             elsif request[:parse_json]
               {}
             else
               body
             end

      {
        status: response.code.to_i,
        data: data,
        headers: response.to_hash
      }
    end

    def net_http_request_class(method)
      {
        "GET" => Net::HTTP::Get,
        "POST" => Net::HTTP::Post,
        "PUT" => Net::HTTP::Put,
        "PATCH" => Net::HTTP::Patch,
        "DELETE" => Net::HTTP::Delete
      }.fetch(method)
    end
  end
end
