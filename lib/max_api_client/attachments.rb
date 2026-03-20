# frozen_string_literal: true

module MaxApiClient
  class Attachment
    def to_h
      raise NotImplementedError, "#{self.class} must implement #to_h"
    end
  end

  class MediaAttachment < Attachment
    attr_reader :token

    def initialize(token: nil)
      @token = token
    end

    def payload
      { token: token }
    end
  end

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

  class VideoAttachment < MediaAttachment
    def to_h
      { type: "video", payload: }
    end
  end

  class AudioAttachment < MediaAttachment
    def to_h
      { type: "audio", payload: }
    end
  end

  class FileAttachment < MediaAttachment
    def to_h
      { type: "file", payload: }
    end
  end

  class StickerAttachment < Attachment
    attr_reader :code

    def initialize(code:)
      @code = code
    end

    def to_h
      { type: "sticker", payload: { code: } }
    end
  end

  class LocationAttachment < Attachment
    attr_reader :longitude, :latitude

    def initialize(lon:, lat:)
      @longitude = lon
      @latitude = lat
    end

    def to_h
      { type: "location", latitude:, longitude: }
    end
  end

  class ShareAttachment < Attachment
    attr_reader :url, :token

    def initialize(url: nil, token: nil)
      @url = url
      @token = token
    end

    def to_h
      { type: "share", payload: { url:, token: } }
    end
  end
end
