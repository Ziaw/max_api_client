# frozen_string_literal: true

module MaxApiClient
  # Base type for all outgoing attachment payload wrappers.
  class Attachment
    def to_h
      raise NotImplementedError, "#{self.class} must implement #to_h"
    end

    def to_json(*args)
      to_h.to_json(*args)
    end

    # Encoders that go through as_json (ActiveSupport's to_json in Rails) get the same
    # payload as JSON.generate instead of the object's instance variables.
    def as_json(*)
      to_h
    end
  end

  # Shared attachment implementation for upload-backed media objects.
  class MediaAttachment < Attachment
    attr_reader :token

    def initialize(token: nil)
      super()
      @token = token
    end

    def payload
      { token: token }
    end
  end

  # Attachment wrapper for uploaded or remote images.
  class ImageAttachment < MediaAttachment
    attr_reader :photos, :url

    def initialize(token: nil, photos: nil, url: nil)
      super(token:)
      @photos = photos
      @url = url
    end

    def payload
      return { token: token } if token
      return { url: url } if url

      { photos: photos }
    end

    def to_h
      { type: "image", payload: }
    end
  end

  # Attachment wrapper for uploaded videos.
  class VideoAttachment < MediaAttachment
    def to_h
      { type: "video", payload: }
    end
  end

  # Attachment wrapper for uploaded audio files.
  class AudioAttachment < MediaAttachment
    def to_h
      { type: "audio", payload: }
    end
  end

  # Attachment wrapper for generic uploaded files.
  class FileAttachment < MediaAttachment
    def to_h
      { type: "file", payload: }
    end
  end

  # Attachment wrapper for sticker references.
  class StickerAttachment < Attachment
    attr_reader :code

    def initialize(code:)
      super()
      @code = code
    end

    def to_h
      { type: "sticker", payload: { code: } }
    end
  end

  # Attachment wrapper for geo coordinates.
  class LocationAttachment < Attachment
    attr_reader :longitude, :latitude

    def initialize(lon:, lat:)
      super()
      @longitude = lon
      @latitude = lat
    end

    def to_h
      { type: "location", latitude:, longitude: }
    end
  end

  # Attachment wrapper for shared links or tokens.
  class ShareAttachment < Attachment
    attr_reader :url, :token

    def initialize(url: nil, token: nil)
      super()
      @url = url
      @token = token
    end

    def to_h
      { type: "share", payload: { url:, token: }.compact }
    end
  end

  # Attachment wrapper for contact cards.
  class ContactAttachment < Attachment
    attr_reader :name, :contact_id, :vcf_info, :vcf_phone

    def initialize(name: nil, contact_id: nil, vcf_info: nil, vcf_phone: nil)
      super()
      @name = name
      @contact_id = contact_id
      @vcf_info = vcf_info
      @vcf_phone = vcf_phone
    end

    def to_h
      { type: "contact", payload: { name:, contact_id:, vcf_info:, vcf_phone: }.compact }
    end
  end

  # Attachment wrapper for an inline keyboard: an array of button rows.
  class InlineKeyboardAttachment < Attachment
    attr_reader :buttons

    def initialize(buttons:)
      super()
      @buttons = buttons
    end

    def to_h
      { type: "inline_keyboard", payload: { buttons: } }
    end
  end

  # Builders for inline keyboard buttons.
  module Button
    module_function

    def callback(text, payload)
      { type: "callback", text:, payload: }
    end

    def link(text, url)
      { type: "link", text:, url: }
    end

    def message(text)
      { type: "message", text: }
    end

    def request_contact(text)
      { type: "request_contact", text: }
    end

    def request_geo_location(text, quick: nil)
      { type: "request_geo_location", text:, quick: }.compact
    end

    def open_app(text, web_app, payload: nil, contact_id: nil)
      { type: "open_app", text:, web_app:, payload:, contact_id: }.compact
    end

    def clipboard(text, payload)
      { type: "clipboard", text:, payload: }
    end
  end
end
