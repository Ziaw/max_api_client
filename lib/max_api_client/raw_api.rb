# frozen_string_literal: true

module MaxApiClient
  class RawApi < BaseApi
    def initialize(client)
      super
      @client = client
    end

    attr_reader :client

    def get(path, query: nil, path_params: nil)
      _get(path, query:, path_params:)
    end
    alias getRaw get

    def post(path, query: nil, body: nil, path_params: nil)
      _post(path, query:, body:, path_params:)
    end

    def put(path, query: nil, body: nil, path_params: nil)
      _put(path, query:, body:, path_params:)
    end

    def patch(path, query: nil, body: nil, path_params: nil)
      _patch(path, query:, body:, path_params:)
    end

    def delete(path, query: nil, body: nil, path_params: nil)
      _delete(path, query:, body:, path_params:)
    end

    def bots
      @bots ||= BotsApi.new(client)
    end

    def chats
      @chats ||= ChatsApi.new(client)
    end

    def messages
      @messages ||= MessagesApi.new(client)
    end

    def subscriptions
      @subscriptions ||= SubscriptionsApi.new(client)
    end

    def uploads
      @uploads ||= UploadsApi.new(client)
    end
  end

  class BotsApi < BaseApi
    def get_my_info
      _get("me")
    end
    alias getMyInfo get_my_info

    def edit_my_info(extra)
      _patch("me", body: extra)
    end
    alias editMyInfo edit_my_info
  end

  class ChatsApi < BaseApi
    def get_all(extra = {})
      _get("chats", query: extra)
    end

    def get_by_id(chat_id:)
      _get("chats/{chat_id}", path_params: { chat_id: })
    end

    def get_by_link(chat_link:)
      _get("chats/{chat_link}", path_params: { chat_link: })
    end

    def edit(chat_id:, **extra)
      _patch("chats/{chat_id}", path_params: { chat_id: }, body: extra)
    end

    def get_chat_membership(chat_id:)
      _get("chats/{chat_id}/members/me", path_params: { chat_id: })
    end

    def get_chat_admins(chat_id:)
      _get("chats/{chat_id}/members/admins", path_params: { chat_id: })
    end

    def add_chat_members(chat_id:, user_ids:)
      _post("chats/{chat_id}/members", path_params: { chat_id: }, body: { user_ids: })
    end

    def get_chat_members(chat_id:, **query)
      _get("chats/{chat_id}/members", path_params: { chat_id: }, query:)
    end

    def remove_chat_member(chat_id:, user_id:, block: nil)
      body = { user_id: }
      body[:block] = block unless block.nil?
      _delete("chats/{chat_id}/members", path_params: { chat_id: }, body:)
    end

    def get_pinned_message(chat_id:)
      _get("chats/{chat_id}/pin", path_params: { chat_id: })
    end

    def pin_message(chat_id:, message_id:, notify: nil)
      body = { message_id: }
      body[:notify] = notify unless notify.nil?
      _put("chats/{chat_id}/pin", path_params: { chat_id: }, body:)
    end

    def unpin_message(chat_id:)
      _delete("chats/{chat_id}/pin", path_params: { chat_id: })
    end

    def send_action(chat_id:, action:)
      _post("chats/{chat_id}/actions", path_params: { chat_id: }, body: { action: })
    end

    def leave_chat(chat_id:)
      _delete("chats/{chat_id}/members/me", path_params: { chat_id: })
    end
  end

  class MessagesApi < BaseApi
    ATTACHMENT_NOT_READY_CODE = "attachment.not.ready"
    ATTACHMENT_NOT_READY_DELAY = 1

    def get(**query)
      _get("messages", query:)
    end

    def get_by_id(message_id:)
      _get("messages/{message_id}", path_params: { message_id: })
    end

    def send(chat_id: nil, user_id: nil, disable_link_preview: nil, **body)
      query = { chat_id:, user_id:, disable_link_preview: }.reject { |_k, v| v.nil? }
      _post("messages", query:, body:)
    rescue ApiError => e
      raise unless e.code == ATTACHMENT_NOT_READY_CODE

      sleep(ATTACHMENT_NOT_READY_DELAY)
      send(chat_id:, user_id:, disable_link_preview:, **body)
    end

    def edit(message_id:, **body)
      _put("messages", query: { message_id: }, body:)
    end

    def delete(message_id:)
      _delete("messages", query: { message_id: })
    end

    def answer_on_callback(callback_id:, **body)
      _post("answers", query: { callback_id: }, body:)
    end
  end

  class SubscriptionsApi < BaseApi
    def get_updates(**query)
      _get("updates", query:)
    end
  end

  class UploadsApi < BaseApi
    def get_upload_url(type:)
      _post("uploads", query: { type: })
    end
  end
end
