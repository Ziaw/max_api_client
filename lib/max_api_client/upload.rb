# frozen_string_literal: true

module MaxApiClient
  # Upload helper that prepares files and sends them to upload endpoints.
  class Upload
    DEFAULT_TIMEOUT = 20
    BINARY_HEADERS = {
      "Content-Type" => "application/x-binary; charset=x-user-defined",
      "X-Uploading-Mode" => "parallel",
      "Connection" => "keep-alive"
    }.freeze

    def initialize(api)
      @api = api
    end

    def image(source: nil, url: nil, timeout: DEFAULT_TIMEOUT, filename: nil)
      return { url: } if url

      upload_from_source("image", source, timeout:, filename:)
    end

    def video(source:, timeout: DEFAULT_TIMEOUT, filename: nil)
      upload_from_source("video", source, timeout:, filename:)
    end

    def audio(source:, timeout: DEFAULT_TIMEOUT, filename: nil)
      upload_from_source("audio", source, timeout:, filename:)
    end

    def file(source:, timeout: DEFAULT_TIMEOUT, filename: nil)
      upload_from_source("file", source, timeout:, filename:)
    end

    private

    attr_reader :api

    def upload_from_source(type, source, timeout:, filename:)
      upload(type, file_from_source(source, filename:), timeout:)
    end

    def upload(type, file, timeout:)
      response = api.raw.uploads.get_upload_url(type:)
      upload_url = fetch_value(response, :url)
      token = fetch_value(response, :token)

      return { token: }.tap { upload_binary(upload_url, file, timeout:) } if token

      upload_multipart(upload_url, file, timeout:)
    end

    def upload_binary(upload_url, file, timeout:)
      headers = BINARY_HEADERS.merge(
        "Content-Disposition" => %(attachment; filename="#{file[:filename]}"),
        "Content-Range" => "bytes 0-#{file[:content].bytesize - 1}/#{file[:content].bytesize}",
        "X-File-Name" => file[:filename]
      )

      result = api.client.call(
        method: :post,
        url: upload_url,
        raw_body: file[:content],
        headers: headers,
        parse_json: false
      )

      raise ApiError.new(result[:status], { message: result[:data] }) if result[:status] >= 400
    end

    def upload_multipart(upload_url, file, timeout:)
      boundary = "----max-api-client-#{SecureRandom.hex(12)}"
      body = build_multipart_body(boundary, file)
      headers = {
        "Content-Type" => "multipart/form-data; boundary=#{boundary}"
      }

      result = api.client.call(
        method: :post,
        url: upload_url,
        raw_body: body,
        headers: headers,
        parse_json: true
      )

      raise ApiError.new(result[:status], result[:data]) if result[:status] >= 400

      result[:data]
    end

    def build_multipart_body(boundary, file)
      [
        "--#{boundary}\r\n",
        %(Content-Disposition: form-data; name="data"; filename="#{file[:filename]}"\r\n),
        "Content-Type: application/octet-stream\r\n\r\n",
        file[:content],
        "\r\n--#{boundary}--\r\n"
      ].join
    end

    def file_from_source(source, filename: nil)
      raise ArgumentError, "source is required" if source.nil?

      return file_from_path(source, filename:) if source.is_a?(String) && File.file?(source)
      return file_from_io(source, filename:) if source.respond_to?(:read)

      raise ArgumentError, "source must be a file path or readable IO"
    end

    def file_from_path(source, filename:)
      {
        filename: filename || File.basename(source),
        content: File.binread(source)
      }
    end

    def file_from_io(source, filename:)
      current_pos = source.pos if source.respond_to?(:pos)
      source.rewind if source.respond_to?(:rewind)
      content = source.read
      source.pos = current_pos if current_pos && source.respond_to?(:pos=)

      {
        filename: filename || io_filename(source),
        content:
      }
    end

    def io_filename(source)
      if source.respond_to?(:path) && source.path.is_a?(String)
        File.basename(source.path)
      else
        SecureRandom.uuid
      end
    end

    def fetch_value(hash, key)
      hash[key] || hash[key.to_s]
    end
  end
end
