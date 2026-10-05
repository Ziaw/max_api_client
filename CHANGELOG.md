## [Unreleased]

- Attachment objects implement `as_json`, so ActiveSupport's `to_json` (Rails) serializes them the same as `JSON.generate` instead of dumping instance variables.

## [0.2.0] - 2026-10-03

Synced with Max Bot API schema 0.0.33.

- Added `edit_my_commands` (`PATCH /me/commands`); `set_my_commands` and `delete_my_commands` now use it instead of `PATCH /me`.
- Added `add_chat_admins` and `remove_chat_admin`.
- Added comment methods: `get_comments`, `get_comment`, `send_comment`, `edit_comment`, `delete_comment` (`api.raw.comments`).
- Added `get_video_info` (`GET /videos/{videoToken}`).
- Added `ContactAttachment`, `InlineKeyboardAttachment` and `Button` builders; attachment objects now serialize to JSON without an explicit `to_h`.
- Added `limit` to `poll_updates`; an empty `types` list is no longer sent.
- Fixed `remove_chat_member`: `user_id` and `block` are sent as query parameters, as the schema requires.
- Fixed `get_message`, which raised `ArgumentError`.
- Fixed `answer_on_callback`: `disable_link_preview` is sent as a query parameter.
- `false` query values are now sent as `false` instead of being dropped.
- Sending a message is retried at most 3 times on `attachment.not.ready`, with exponential backoff.
- `delete_message` no longer accepts extra options (they raised `ArgumentError`).
- Deprecated `edit_my_info`, `get_all_chats`, `get_chat_by_link` and `add_chat_members`: their endpoints are removed from the API or absent from the schema.

## [0.1.3] - 2026-07-16

- Switched the default API endpoint to `https://platform-api2.max.ru`.
- Added the Russian Trusted Root CA to the TLS trust store, with optional `ca_file` override.
- Added an explicit `verify_ssl: false` option for environments that must temporarily ignore certificate errors.
- Documented the new endpoint and TLS configuration options.
- Updated the TypeScript reference client link.

## [0.1.2] - 2026-03-27

- Configured RubyGems trusted publishing through GitHub Actions.
- Added release tag validation and updated the Ruby CI matrix.

## [0.1.0] - 2026-02-12

- Initial release
