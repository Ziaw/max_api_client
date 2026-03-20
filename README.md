# max_api_client

Ruby gem for working with Max Bot API.

The repository also includes the TypeScript client as a git submodule in [`vendor/max-bot-api-client-ts`](./vendor/max-bot-api-client-ts). At the moment, that client is the functional reference implementation, while the Ruby gem is the package scaffold and compatibility target.

## Status

Current Ruby implementation now includes a working API client with:

- high-level `MaxApiClient::Api`
- low-level `MaxApiClient::RawApi`
- grouped bot/chat/message/subscription/upload methods
- attachment helper objects for upload results

The gem is still not a full bot framework with polling/composer/context parity, but the API layer is now aligned with the TypeScript client surface.

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

Clone the repository and initialize the TypeScript reference client:

```bash
git clone git@github.com:Ziaw/max_api_client.git
cd max_api_client
git submodule update --init --recursive
bundle install
```

Useful commands:

```bash
bundle exec rake test
bin/console
```

## Ruby And TypeScript Comparison

The repository currently contains two very different maturity levels.

| Area | TypeScript client | Ruby gem |
| --- | --- | --- |
| Package state | Production-style implementation | Skeleton gem |
| Public API | `Bot`, `Composer`, `Context`, `Api`, attachments, keyboard helpers | `Api`, `RawApi`, attachments, `VERSION`, `Error` |
| Update handling | Long polling via `Bot#start` | `Api#get_updates` implemented, polling framework not implemented |
| Middleware/composition | Implemented | Not implemented |
| Raw API access | Implemented | Implemented |
| File uploads | Implemented | Implemented |
| Convenience methods | Implemented for chats, messages, subscriptions, uploads | Implemented for API layer |
| Documentation | Present in submodule docs | This README documents current state and target API |

In practical terms:

- if you need a working client today, use the TypeScript implementation from the submodule;
- if you are building the Ruby gem, treat the TS client as the compatibility reference;
- README API sections below describe the API surface that should be wrapped by Ruby to reach parity.

## Reference API

The TypeScript client wraps Max Bot API into a convenience `Api` class. The same method groups are the natural target for the Ruby gem.

### Bot Methods

Methods exposed by the TS reference client:

- `getMyInfo`
- `editMyInfo(extra)`
- `setMyCommands(commands)`
- `deleteMyCommands`

Underlying HTTP routes:

- `GET /me`
- `PATCH /me`

Use cases:

- fetch current bot profile;
- update bot name, description, avatar and commands;
- publish or clear command hints shown to users.

### Chat Methods

Methods exposed by the TS reference client:

- `getAllChats(extra = {})`
- `getChat(chat_id)`
- `getChatByLink(chat_link)`
- `editChatInfo(chat_id, extra)`
- `getChatMembership(chat_id)`
- `getChatAdmins(chat_id)`
- `addChatMembers(chat_id, user_ids)`
- `getChatMembers(chat_id, extra = {})`
- `removeChatMember(chat_id, user_id)`
- `getPinnedMessage(chat_id)`
- `pinMessage(chat_id, message_id, extra = {})`
- `unpinMessage(chat_id)`
- `sendAction(chat_id, action)`
- `leaveChat(chat_id)`

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

Methods exposed by the TS reference client:

- `sendMessageToChat(chat_id, text, extra = nil)`
- `sendMessageToUser(user_id, text, extra = nil)`
- `getMessages(chat_id, extra = {})`
- `getMessage(message_id)`
- `editMessage(message_id, extra = {})`
- `deleteMessage(message_id, extra = {})`
- `answerOnCallback(callback_id, extra = {})`

Underlying HTTP routes:

- `POST /messages`
- `GET /messages`
- `GET /messages/{message_id}`
- `PUT /messages`
- `DELETE /messages`
- `POST /answers`

Supported concerns in the TS client:

- plain text sending to chat or direct user;
- extra payload for formatting, reply links and attachments;
- message editing and deletion;
- callback button answers;
- automatic retry when upload-backed attachments are not yet ready.

### Subscription Methods

Methods exposed by the TS reference client:

- `getUpdates(types = [], extra = {})`

Underlying HTTP route:

- `GET /updates`

This is the base used by the TS bot framework for long polling.

### Upload Methods

Methods exposed by the TS reference client:

- `uploadImage(options)`
- `uploadVideo(options)`
- `uploadAudio(options)`
- `uploadFile(options)`

Related HTTP route:

- `POST /uploads`

The TS implementation also includes upload helpers and attachment wrappers such as:

- `ImageAttachment`
- `VideoAttachment`
- `AudioAttachment`
- `FileAttachment`
- `StickerAttachment`
- `LocationAttachment`
- `ShareAttachment`

### Raw API Access

The TypeScript client exposes low-level access through `api.raw` and supports:

- `get`
- `post`
- `put`
- `patch`
- `delete`

This matters for parity because it lets the client call new or unsupported endpoints before high-level wrappers are added.

## Target Ruby Surface

A reasonable Ruby parity target based on the TS client would be:

```ruby
client = MaxApiClient::Api.new(token: ENV.fetch("MAX_BOT_TOKEN"))

client.get_my_info
client.set_my_commands([{ name: "ping", description: "Ping command" }])
client.send_message_to_chat(123, "Hello", format: "markdown")
client.get_updates(%w[message_created])
client.raw.get("me")
client.upload_image(url: "https://example.com/picture.png")
```

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
- Embedded TS reference in this repo: [`vendor/max-bot-api-client-ts`](./vendor/max-bot-api-client-ts)

## License

Released under the MIT License. See [`LICENSE.txt`](./LICENSE.txt).
