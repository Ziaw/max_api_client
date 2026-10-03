# frozen_string_literal: true

module MaxApiClient
  # High-level convenience wrapper over grouped Max Bot API endpoints.
  # rubocop:disable Metrics/ClassLength
  class Api
    attr_reader :raw, :upload, :client

    # rubocop:disable Metrics/ParameterLists
    def initialize(token:, base_url: Client::DEFAULT_BASE_URL, adapter: nil, open_timeout: nil, read_timeout: nil,
                   ca_file: Client::DEFAULT_CA_FILE, verify_ssl: true, logger: nil)
      @client = Client.new(
        token:,
        base_url:,
        adapter:,
        open_timeout:,
        read_timeout:,
        ca_file:,
        verify_ssl:,
        logger:
      )
      @raw = RawApi.new(client)
      @upload = Upload.new(self)
    end
    # rubocop:enable Metrics/ParameterLists

    # rubocop:disable Naming/AccessorMethodName
    def get_my_info
      raw.bots.get_my_info
    end
    # rubocop:enable Naming/AccessorMethodName

    def edit_my_info(**extra)
      warn_deprecated(:edit_my_info, "PATCH /me is absent from the current API schema, use edit_my_commands")
      raw.bots.edit_my_info(**extra)
    end

    def edit_my_commands(commands)
      raw.bots.edit_my_commands(commands:)
    end

    # rubocop:disable Naming/AccessorMethodName
    def set_my_commands(commands)
      edit_my_commands(commands)
    end
    # rubocop:enable Naming/AccessorMethodName

    def delete_my_commands
      edit_my_commands([])
    end

    def get_all_chats(**extra)
      warn_deprecated(:get_all_chats, "GET /chats is not supported by the API since June 2026")
      raw.chats.get_all(**extra)
    end

    def get_chat(chat_id)
      raw.chats.get_by_id(chat_id:)
    end

    def get_chat_by_link(chat_link)
      warn_deprecated(:get_chat_by_link, "lookup by link is absent from the current API schema")
      raw.chats.get_by_link(chat_link:)
    end

    def edit_chat_info(chat_id, **extra)
      raw.chats.edit(chat_id:, **extra)
    end

    def get_chat_membership(chat_id)
      raw.chats.get_chat_membership(chat_id:)
    end

    def get_chat_admins(chat_id)
      raw.chats.get_chat_admins(chat_id:)
    end

    def add_chat_admins(chat_id, admins)
      raw.chats.add_chat_admins(chat_id:, admins:)
    end

    def remove_chat_admin(chat_id, user_id)
      raw.chats.remove_chat_admin(chat_id:, user_id:)
    end

    def add_chat_members(chat_id, user_ids)
      warn_deprecated(:add_chat_members, "POST /chats/{chat_id}/members was removed from the API on 2026-09-30")
      raw.chats.add_chat_members(chat_id:, user_ids:)
    end

    def get_chat_members(chat_id, **extra)
      raw.chats.get_chat_members(chat_id:, **csv_query(extra, :user_ids))
    end

    def remove_chat_member(chat_id, user_id, block: nil)
      raw.chats.remove_chat_member(chat_id:, user_id:, block:)
    end

    def get_pinned_message(chat_id)
      raw.chats.get_pinned_message(chat_id:)
    end

    def pin_message(chat_id, message_id, **extra)
      raw.chats.pin_message(chat_id:, message_id:, notify: extra[:notify])
    end

    def unpin_message(chat_id)
      raw.chats.unpin_message(chat_id:)
    end

    def send_action(chat_id, action)
      raw.chats.send_action(chat_id:, action:)
    end

    def leave_chat(chat_id)
      raw.chats.leave_chat(chat_id:)
    end

    def send_message_to_chat(chat_id, text, **extra)
      message_from(raw.messages.send(chat_id:, text:, **extra))
    end

    def send_message_to_user(user_id, text, **extra)
      message_from(raw.messages.send(user_id:, text:, **extra))
    end

    def get_messages(chat_id, **extra)
      raw.messages.get(chat_id:, **csv_query(extra, :message_ids))
    end

    def get_message(message_id)
      raw.messages.get_by_id(message_id:)
    end

    def edit_message(message_id, **extra)
      raw.messages.edit(message_id:, **extra)
    end

    def delete_message(message_id)
      raw.messages.delete(message_id:)
    end

    def get_video_info(video_token)
      raw.messages.get_video_info(video_token:)
    end

    def answer_on_callback(callback_id, **extra)
      raw.messages.answer_on_callback(callback_id:, **extra)
    end

    def get_comments(message_id, **extra)
      raw.comments.get(message_id:, **csv_query(extra, :comment_ids))
    end

    def get_comment(message_id, comment_id)
      raw.comments.get_by_id(message_id:, comment_id:)
    end

    def send_comment(message_id, text, **extra)
      message_from(raw.comments.send(message_id:, text:, **extra))
    end

    def edit_comment(message_id, comment_id, **extra)
      raw.comments.edit(message_id:, comment_id:, **extra)
    end

    def delete_comment(message_id, comment_id)
      raw.comments.delete(message_id:, comment_id:)
    end

    # rubocop:disable Naming/AccessorMethodName
    def get_subscriptions
      raw.subscriptions.get_subscriptions
    end
    # rubocop:enable Naming/AccessorMethodName

    def subscribe(url, update_types: nil, secret: nil)
      raw.subscriptions.subscribe(url:, update_types:, secret:)
    end

    def unsubscribe(url)
      raw.subscriptions.unsubscribe(url:)
    end

    # rubocop:disable Metrics/ParameterLists
    def poll_updates(types = [], marker: nil, limit: nil, timeout: Polling::DEFAULT_TIMEOUT,
                     retry_interval: Polling::DEFAULT_RETRY_INTERVAL, read_timeout: nil, &block)
      poller = Polling.new(
        self,
        types:,
        marker:,
        limit:,
        timeout:,
        retry_interval:,
        read_timeout:
      )

      return poller.each unless block

      poller.each(&block)
    end
    # rubocop:enable Metrics/ParameterLists

    def upload_image(options)
      data = upload.image(**options)
      ImageAttachment.new(token: data[:token], photos: data[:photos], url: data[:url] || data["url"])
    end

    def upload_video(options)
      data = upload.video(**options)
      VideoAttachment.new(token: data[:token] || data["token"])
    end

    def upload_audio(options)
      data = upload.audio(**options)
      AudioAttachment.new(token: data[:token] || data["token"])
    end

    def upload_file(options)
      data = upload.file(**options)
      FileAttachment.new(token: data[:token] || data["token"])
    end

    private

    def normalize_types(types)
      return types unless types.is_a?(Array)

      types.join(",")
    end

    def csv_query(query, key)
      query.merge(key => normalize_types(query[key]))
    end

    def warn_deprecated(method_name, reason)
      warn("[max_api_client] #{method_name} is deprecated: #{reason}", uplevel: 2)
    end

    def message_from(response)
      response.fetch("message") { response.fetch(:message) }
    end
  end
  # rubocop:enable Metrics/ClassLength
end
