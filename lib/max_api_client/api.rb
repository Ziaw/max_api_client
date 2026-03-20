# frozen_string_literal: true

module MaxApiClient
  class Api
    attr_reader :raw, :upload, :client

    def initialize(token:, base_url: Client::DEFAULT_BASE_URL, adapter: nil, open_timeout: nil, read_timeout: nil)
      @client = Client.new(
        token:,
        base_url:,
        adapter:,
        open_timeout:,
        read_timeout:
      )
      @raw = RawApi.new(client)
      @upload = Upload.new(self)
    end

    def get_my_info
      raw.bots.get_my_info
    end
    alias getMyInfo get_my_info

    def edit_my_info(extra)
      raw.bots.edit_my_info(extra)
    end
    alias editMyInfo edit_my_info

    def set_my_commands(commands)
      edit_my_info(commands:)
    end
    alias setMyCommands set_my_commands

    def delete_my_commands
      edit_my_info(commands: [])
    end
    alias deleteMyCommands delete_my_commands

    def get_all_chats(extra = {})
      raw.chats.get_all(extra)
    end
    alias getAllChats get_all_chats

    def get_chat(chat_id)
      raw.chats.get_by_id(chat_id:)
    end
    alias getChat get_chat

    def get_chat_by_link(chat_link)
      raw.chats.get_by_link(chat_link:)
    end
    alias getChatByLink get_chat_by_link

    def edit_chat_info(chat_id, extra)
      raw.chats.edit(chat_id:, **extra)
    end
    alias editChatInfo edit_chat_info

    def get_chat_membership(chat_id)
      raw.chats.get_chat_membership(chat_id:)
    end
    alias getChatMembership get_chat_membership

    def get_chat_admins(chat_id)
      raw.chats.get_chat_admins(chat_id:)
    end
    alias getChatAdmins get_chat_admins

    def add_chat_members(chat_id, user_ids)
      raw.chats.add_chat_members(chat_id:, user_ids:)
    end
    alias addChatMembers add_chat_members

    def get_chat_members(chat_id, extra = {})
      raw.chats.get_chat_members(chat_id:, **csv_query(extra, :user_ids))
    end
    alias getChatMembers get_chat_members

    def remove_chat_member(chat_id, user_id, block: nil)
      raw.chats.remove_chat_member(chat_id:, user_id:, block:)
    end
    alias removeChatMember remove_chat_member

    def get_pinned_message(chat_id)
      raw.chats.get_pinned_message(chat_id:)
    end
    alias getPinnedMessage get_pinned_message

    def pin_message(chat_id, message_id, extra = {})
      raw.chats.pin_message(chat_id:, message_id:, notify: extra[:notify])
    end
    alias pinMessage pin_message

    def unpin_message(chat_id)
      raw.chats.unpin_message(chat_id:)
    end
    alias unpinMessage unpin_message

    def send_action(chat_id, action)
      raw.chats.send_action(chat_id:, action:)
    end
    alias sendAction send_action

    def leave_chat(chat_id)
      raw.chats.leave_chat(chat_id:)
    end
    alias leaveChat leave_chat

    def send_message_to_chat(chat_id, text, extra = nil)
      message_from(raw.messages.send(chat_id:, text:, **(extra || {})))
    end
    alias sendMessageToChat send_message_to_chat

    def send_message_to_user(user_id, text, extra = nil)
      message_from(raw.messages.send(user_id:, text:, **(extra || {})))
    end
    alias sendMessageToUser send_message_to_user

    def get_messages(chat_id, extra = {})
      raw.messages.get(chat_id:, **csv_query(extra, :message_ids))
    end
    alias getMessages get_messages

    def get_message(message_id)
      raw.messages.get_by_id(message_id:)
    end
    alias getMessage get_message

    def edit_message(message_id, extra = {})
      raw.messages.edit(message_id:, **extra)
    end
    alias editMessage edit_message

    def delete_message(message_id, extra = {})
      raw.messages.delete(message_id:, **extra)
    end
    alias deleteMessage delete_message

    def answer_on_callback(callback_id, extra = {})
      raw.messages.answer_on_callback(callback_id:, **extra)
    end
    alias answerOnCallback answer_on_callback

    def get_updates(types = [], extra = {})
      raw.subscriptions.get_updates(types: normalize_types(types), **extra)
    end
    alias getUpdates get_updates

    def upload_image(options)
      data = upload.image(**options)
      ImageAttachment.new(token: data[:token], photos: data[:photos], url: data[:url] || data["url"])
    end
    alias uploadImage upload_image

    def upload_video(options)
      data = upload.video(**options)
      VideoAttachment.new(token: data[:token] || data["token"])
    end
    alias uploadVideo upload_video

    def upload_audio(options)
      data = upload.audio(**options)
      AudioAttachment.new(token: data[:token] || data["token"])
    end
    alias uploadAudio upload_audio

    def upload_file(options)
      data = upload.file(**options)
      FileAttachment.new(token: data[:token] || data["token"])
    end
    alias uploadFile upload_file

    private

    def normalize_types(types)
      return types unless types.is_a?(Array)

      types.join(",")
    end

    def csv_query(query, key)
      query.merge(key => normalize_types(query[key]))
    end

    def message_from(response)
      response.fetch("message") { response.fetch(:message) }
    end
  end
end
