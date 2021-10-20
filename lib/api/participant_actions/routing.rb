# frozen_string_literal: true

module Api
  module ParticipantActions
    class Routing
      def call(mapper, _options = {})
        mapper.member { mapper.put :withdraw }
        mapper.member { mapper.put :defer }
      end
    end
  end
end
