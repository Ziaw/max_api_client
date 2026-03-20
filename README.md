# max_api_client

Ruby gem for working with Max Bot API.

## Status

Current Ruby implementation now includes a working API client with:

- high-level `MaxApiClient::Api`
- low-level `MaxApiClient::RawApi`
- grouped bot/chat/message/subscription/upload methods
- attachment helper objects for upload results

## Installation

Add the gem to your project:

```ruby
# Gemfile
gem "max_api_client", git: "git@github.com:Ziaw/max_api_client.git"
```

Or install locally during development:

```bash
bundle install
bundle exec rake install
```

## Development

Clone the repository and install dependencies:

```bash
git clone git@github.com:Ziaw/max_api_client.git
cd max_api_client
bundle install
```

Useful commands:

```bash
bundle exec rake test
bin/console
```

## Reference API

### Bot Methods

Ruby methods exposed by `MaxApiClient::Api`:

- `get_my_info`
- `edit_my_info(extra)`
- `set_my_commands(commands)`
- `delete_my_commands`

Underlying HTTP routes:

- `GET /me`
- `PATCH /me`

Use cases:

- fetch current bot profile;
- update bot name, description, avatar and commands;
- publish or clear command hints shown to users.

### Chat Methods

Ruby methods exposed by `MaxApiClient::Api`:

- `get_all_chats(extra = {})`
- `get_chat(chat_id)`
- `get_chat_by_link(chat_link)`
- `edit_chat_info(chat_id, extra)`
- `get_chat_membership(chat_id)`
- `get_chat_admins(chat_id)`
- `add_chat_members(chat_id, user_ids)`
- `get_chat_members(chat_id, extra = {})`
- `remove_chat_member(chat_id, user_id)`
- `get_pinned_message(chat_id)`
- `pin_message(chat_id, message_id, extra = {})`
- `unpin_message(chat_id)`
- `send_action(chat_id, action)`
- `leave_chat(chat_id)`

Underlying HTTP routes:

- `GET /chats`
- `GET /chats/{chat_id}`
- `GET /chats/{chat_link}`
- `PATCH /chats/{chat_id}`
- `GET /chats/{chat_id}/members/me`
- `GET /chats/{chat_id}/members/admins`
- `POST /chats/{chat_id}/members`
- `GET /chats/{chat_id}/members`
- `DELETE /chats/{chat_id}/members`
- `GET /chats/{chat_id}/pin`
- `PUT /chats/{chat_id}/pin`
- `DELETE /chats/{chat_id}/pin`
- `POST /chats/{chat_id}/actions`
- `DELETE /chats/{chat_id}/members/me`

Use cases:

- enumerate chats available to the bot;
- resolve chat by id or public link;
- edit title, icon and chat metadata;
- manage membership and admins;
- read, set and clear pinned messages;
- send typing or other sender actions;
- leave a chat.

### Message Methods

Ruby methods exposed by `MaxApiClient::Api`:

- `send_message_to_chat(chat_id, text, extra = nil)`
- `send_message_to_user(user_id, text, extra = nil)`
- `get_messages(chat_id, extra = {})`
- `get_message(message_id)`
- `edit_message(message_id, extra = {})`
- `delete_message(message_id, extra = {})`
- `answer_on_callback(callback_id, extra = {})`

Underlying HTTP routes:

- `POST /messages`
- `GET /messages`
- `GET /messages/{message_id}`
- `PUT /messages`
- `DELETE /messages`
- `POST /answers`

Supported concerns:

- plain text sending to chat or direct user;
- extra payload for formatting, reply links and attachments;
- message editing and deletion;
- callback button answers;
- automatic retry when upload-backed attachments are not yet ready.

### Subscription Methods

Ruby methods exposed by `MaxApiClient::Api`:

- `get_updates(types = [], extra = {})`

Underlying HTTP route:

- `GET /updates`

### Upload Methods

Ruby methods exposed by `MaxApiClient::Api`:

- `upload_image(options)`
- `upload_video(options)`
- `upload_audio(options)`
- `upload_file(options)`

Related HTTP route:

- `POST /uploads`

Attachment helpers:

- `ImageAttachment`
- `VideoAttachment`
- `AudioAttachment`
- `FileAttachment`
- `StickerAttachment`
- `LocationAttachment`
- `ShareAttachment`

### Raw API Access

Low-level access through `api.raw` supports:

- `get`
- `post`
- `put`
- `patch`
- `delete`

## Implementation Priorities

Recommended order for building the Ruby client:

1. HTTP client and error layer.
2. Raw request interface.
3. High-level `Api` wrapper for bot, chat, message and update endpoints.
4. Upload flow and attachment objects.
5. Optional bot framework with polling, context and middleware.

## Sources

- Official Max Bot API docs: <https://dev.max.ru/>
- TypeScript reference client: <https://github.com/max-messenger/max-bot-api-client-ts>

## License

Released under the MIT License. See [`LICENSE.txt`](./LICENSE.txt).
