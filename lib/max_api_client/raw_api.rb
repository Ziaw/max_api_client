# frozen_string_literal: true

module MaxApiClient
  # Low-level grouped access to Max Bot API endpoint families.
  class RawApi < BaseApi
    attr_reader :client

    def bots
      @bots ||= build_api(BotsApi)
    end

    def chats
      @chats ||= build_api(ChatsApi)
    end

    def messages
      @messages ||= build_api(MessagesApi)
    end

    def comments
      @comments ||= build_api(CommentsApi)
    end

    def subscriptions
      @subscriptions ||= build_api(SubscriptionsApi)
    end

    def uploads
      @uploads ||= build_api(UploadsApi)
    end

    private

    def build_api(klass)
      klass.new(client)
    end
  end

  # Raw bot profile endpoints.
  class BotsApi < BaseApi
    # rubocop:disable Naming/AccessorMethodName
    def get_my_info
      get("me")
    end
    # rubocop:enable Naming/AccessorMethodName

    # PATCH /me is absent from the current API schema; prefer #edit_my_commands.
    def edit_my_info(**extra)
      patch("me", body: extra)
    end

    def edit_my_commands(commands:)
      patch("me/commands", body: { commands: })
    end
  end

  # Raw chat management endpoints.
  class ChatsApi < BaseApi
    # GET /chats is no longer supported by the API since June 2026.
    def get_all(**extra)
      get("chats", query: extra)
    end

    def get_by_id(chat_id:)
      get("chats/{chat_id}", path_params: { chat_id: })
    end

    # Lookup by public link is absent from the current API schema.
    def get_by_link(chat_link:)
      get("chats/{chat_link}", path_params: { chat_link: })
    end

    def edit(chat_id:, **extra)
      patch("chats/{chat_id}", path_params: { chat_id: }, body: extra)
    end

    def get_chat_membership(chat_id:)
      get("chats/{chat_id}/members/me", path_params: { chat_id: })
    end

    def get_chat_admins(chat_id:)
      get("chats/{chat_id}/members/admins", path_params: { chat_id: })
    end

    def add_chat_admins(chat_id:, admins:)
      post("chats/{chat_id}/members/admins", path_params: { chat_id: }, body: { admins: })
    end

    def remove_chat_admin(chat_id:, user_id:)
      delete("chats/{chat_id}/members/admins/{user_id}", path_params: { chat_id:, user_id: })
    end

    # POST /chats/{chat_id}/members was removed from the API on 2026-09-30.
    def add_chat_members(chat_id:, user_ids:)
      post("chats/{chat_id}/members", path_params: { chat_id: }, body: { user_ids: })
    end

    def get_chat_members(chat_id:, **query)
      get("chats/{chat_id}/members", path_params: { chat_id: }, query:)
    end

    def remove_chat_member(chat_id:, user_id:, block: nil)
      delete("chats/{chat_id}/members", path_params: { chat_id: }, query: compact_nil(user_id:, block:))
    end

    def get_pinned_message(chat_id:)
      get("chats/{chat_id}/pin", path_params: { chat_id: })
    end

    def pin_message(chat_id:, message_id:, notify: nil)
      put("chats/{chat_id}/pin", path_params: { chat_id: }, body: compact_nil(message_id:, notify:))
    end

    def unpin_message(chat_id:)
      delete("chats/{chat_id}/pin", path_params: { chat_id: })
    end

    def send_action(chat_id:, action:)
      post("chats/{chat_id}/actions", path_params: { chat_id: }, body: { action: })
    end

    def leave_chat(chat_id:)
      delete("chats/{chat_id}/members/me", path_params: { chat_id: })
    end
  end

  # Raw message delivery and mutation endpoints.
  class MessagesApi < BaseApi
    ATTACHMENT_NOT_READY_CODE = "attachment.not.ready"
    ATTACHMENT_NOT_READY_DELAY = 1
    ATTACHMENT_NOT_READY_RETRIES = 3

    def get(**query)
      super("messages", query:)
    end

    def get_by_id(message_id:)
      call_api(:get, "messages/{message_id}", path_params: { message_id: })
    end

    def send(chat_id: nil, user_id: nil, disable_link_preview: nil, **body)
      attempt = 0

      begin
        post("messages", query: compact_nil(chat_id:, user_id:, disable_link_preview:), body:)
      rescue ApiError => e
        raise unless e.code == ATTACHMENT_NOT_READY_CODE

        attempt += 1
        raise if attempt >= ATTACHMENT_NOT_READY_RETRIES

        sleep(ATTACHMENT_NOT_READY_DELAY * (2**(attempt - 1)))
        retry
      end
    end

    def edit(message_id:, **body)
      put("messages", query: { message_id: }, body:)
    end

    def delete(message_id:)
      super("messages", query: { message_id: })
    end

    def get_video_info(video_token:)
      call_api(:get, "videos/{video_token}", path_params: { video_token: })
    end

    def answer_on_callback(callback_id:, disable_link_preview: nil, **body)
      post("answers", query: compact_nil(callback_id:, disable_link_preview:), body:)
    end
  end

  # Raw endpoints for comments under channel posts.
  class CommentsApi < BaseApi
    def get(message_id:, **query)
      super("messages/{message_id}/comments", path_params: { message_id: }, query:)
    end

    def get_by_id(message_id:, comment_id:)
      call_api(:get, "messages/{message_id}/comments/{comment_id}", path_params: { message_id:, comment_id: })
    end

    def send(message_id:, disable_link_preview: nil, **body)
      post("messages/{message_id}/comments", path_params: { message_id: },
                                             query: compact_nil(disable_link_preview:), body:)
    end

    def edit(message_id:, comment_id:, **body)
      put("messages/{message_id}/comments", path_params: { message_id: }, query: { comment_id: }, body:)
    end

    def delete(message_id:, comment_id:)
      super("messages/{message_id}/comments", path_params: { message_id: }, query: { comment_id: })
    end
  end

  # Raw update subscription endpoints.
  class SubscriptionsApi < BaseApi
    # rubocop:disable Naming/AccessorMethodName
    def get_subscriptions
      get("subscriptions")
    end
    # rubocop:enable Naming/AccessorMethodName

    def subscribe(url:, update_types: nil, secret: nil)
      post("subscriptions", body: compact_nil(url:, update_types:, secret:))
    end

    def unsubscribe(url:)
      delete("subscriptions", query: { url: })
    end

    def get_updates(read_timeout: nil, **query)
      get("updates", query:, read_timeout:)
    end
  end

  # Raw upload URL acquisition endpoints.
  class UploadsApi < BaseApi
    def get_upload_url(type:)
      post("uploads", query: { type: })
    end
  end
end
