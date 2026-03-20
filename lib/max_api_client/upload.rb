# frozen_string_literal: true

module MaxApiClient
  class Upload
    DEFAULT_TIMEOUT = 20

    def initialize(api)
      @api = api
    end

    def image(source: nil, url: nil, timeout: DEFAULT_TIMEOUT, filename: nil)
      return { url: } if url

      file = file_from_source(source, filename:)
      upload("image", file, timeout:)
    end

    def video(source:, timeout: DEFAULT_TIMEOUT, filename: nil)
      file = file_from_source(source, filename:)
      upload("video", file, timeout:)
    end

    def audio(source:, timeout: DEFAULT_TIMEOUT, filename: nil)
      file = file_from_source(source, filename:)
      upload("audio", file, timeout:)
    end

    def file(source:, timeout: DEFAULT_TIMEOUT, filename: nil)
      file = file_from_source(source, filename:)
      upload("file", file, timeout:)
    end

    private

    attr_reader :api

    def upload(type, file, timeout:)
      response = api.raw.uploads.get_upload_url(type:)
      upload_url = response.fetch("url") { response.fetch(:url) }
      token = response["token"] || response[:token]

      if token
        upload_binary(upload_url, file, timeout:)
        { token: }
      else
        upload_multipart(upload_url, file, timeout:)
      end
    end

    def upload_binary(upload_url, file, timeout:)
      headers = {
        "Content-Disposition" => %(attachment; filename="#{file[:filename]}"),
        "Content-Range" => "bytes 0-#{file[:content].bytesize - 1}/#{file[:content].bytesize}",
        "Content-Type" => "application/x-binary; charset=x-user-defined",
        "X-File-Name" => file[:filename],
        "X-Uploading-Mode" => "parallel",
        "Connection" => "keep-alive"
      }

      result = api.client.call(
        method: "POST",
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
        method: "POST",
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

      if source.is_a?(String) && File.file?(source)
        {
          filename: filename || File.basename(source),
          content: File.binread(source)
        }
      elsif source.respond_to?(:read)
        current_pos = source.pos if source.respond_to?(:pos)
        source.rewind if source.respond_to?(:rewind)
        content = source.read
        source.pos = current_pos if current_pos && source.respond_to?(:pos=)
        {
          filename: filename || io_filename(source),
          content: content
        }
      else
        raise ArgumentError, "source must be a file path or readable IO"
      end
    end

    def io_filename(source)
      if source.respond_to?(:path) && source.path.is_a?(String)
        File.basename(source.path)
      else
        SecureRandom.uuid
      end
    end
  end
end
