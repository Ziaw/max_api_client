# frozen_string_literal: true

module MaxApiClient
  # Long-polling helper over GET /updates with marker tracking and retries.
  class Polling
    DEFAULT_TIMEOUT = 20
    DEFAULT_RETRY_INTERVAL = 5
    READ_TIMEOUT_PADDING = 5
    RETRYABLE_ERRORS = [
      Net::OpenTimeout,
      Net::ReadTimeout,
      EOFError,
      IOError,
      SocketError,
      Errno::ECONNRESET
    ].freeze

    def initialize(api, types: [], marker: nil, timeout: DEFAULT_TIMEOUT, retry_interval: DEFAULT_RETRY_INTERVAL,
                   read_timeout: nil)
      @api = api
      @types = types
      @marker = marker
      @timeout = timeout
      @retry_interval = retry_interval
      @read_timeout = read_timeout || (timeout.to_i + READ_TIMEOUT_PADDING)
      @stopped = false
    end

    def each
      return enum_for(:each) unless block_given?

      until stopped?
        begin
          response = fetch_updates
          @marker = fetch_value(response, :marker)

          Array(fetch_value(response, :updates)).each do |update|
            break if stopped?

            yield update
          end
        rescue *RETRYABLE_ERRORS
          retry_later
        rescue ApiError => e
          raise unless retryable_status?(e.status)

          retry_later
        end
      end

      self
    end

    def stop
      @stopped = true
    end

    def stopped?
      @stopped
    end

    private

    attr_reader :api, :types, :marker, :timeout, :retry_interval, :read_timeout

    def fetch_updates
      api.raw.subscriptions.get_updates(
        types: normalize_types(types),
        marker:,
        timeout:,
        read_timeout:
      )
    end

    def retry_later
      sleep(retry_interval)
    end

    def retryable_status?(status)
      status == 429 || status >= 500
    end

    def fetch_value(hash, key)
      hash[key] || hash[key.to_s]
    end

    def normalize_types(value)
      return value.join(",") if value.is_a?(Array)

      value
    end
  end
end
