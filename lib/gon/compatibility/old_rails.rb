require 'securerandom'

class Gon
  module GonHelpers
    private

    def gon_request_uuid
      @gon_request_uuid ||= SecureRandom.uuid
    end
  end
end
