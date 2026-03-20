# frozen_string_literal: true

module MaxApiClient
  # Base type for all outgoing attachment payload wrappers.
  class Attachment
    def to_h
      raise NotImplementedError, "#{self.class} must implement #to_h"
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
      { type: "share", payload: { url:, token: } }
    end
  end
end
