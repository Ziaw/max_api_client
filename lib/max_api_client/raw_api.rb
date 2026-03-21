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

    def edit_my_info(**extra)
      patch("me", body: extra)
    end
  end

  # Raw chat management endpoints.
  class ChatsApi < BaseApi
    def get_all(**extra)
      get("chats", query: extra)
    end

    def get_by_id(chat_id:)
      get("chats/{chat_id}", path_params: { chat_id: })
    end

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

    def add_chat_members(chat_id:, user_ids:)
      post("chats/{chat_id}/members", path_params: { chat_id: }, body: { user_ids: })
    end

    def get_chat_members(chat_id:, **query)
      get("chats/{chat_id}/members", path_params: { chat_id: }, query:)
    end

    def remove_chat_member(chat_id:, user_id:, block: nil)
      delete("chats/{chat_id}/members", path_params: { chat_id: }, body: compact_nil(user_id:, block:))
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

    def get(**query)
      super("messages", query:)
    end

    def get_by_id(message_id:)
      get("messages/{message_id}", path_params: { message_id: })
    end

    def send(chat_id: nil, user_id: nil, disable_link_preview: nil, **body)
      post("messages", query: compact_nil(chat_id:, user_id:, disable_link_preview:), body:)
    rescue ApiError => e
      raise unless e.code == ATTACHMENT_NOT_READY_CODE

      sleep(ATTACHMENT_NOT_READY_DELAY)
      send(chat_id:, user_id:, disable_link_preview:, **body)
    end

    def edit(message_id:, **body)
      put("messages", query: { message_id: }, body:)
    end

    def delete(message_id:)
      super("messages", query: { message_id: })
    end

    def answer_on_callback(callback_id:, **body)
      post("answers", query: { callback_id: }, body:)
    end
  end

  # Raw update subscription endpoints.
  class SubscriptionsApi < BaseApi
    def get_updates(**query)
      get("updates", query:)
    end
  end

  # Raw upload URL acquisition endpoints.
  class UploadsApi < BaseApi
    def get_upload_url(type:)
      post("uploads", query: { type: })
    end
  end
end
