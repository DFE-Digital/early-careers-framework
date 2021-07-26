# frozen_string_literal: true

module Admin
  module Participants
    class Details < BaseComponent
      def initialize(profile:)
        @profile = profile
      end

      def call
        delegate_component = self.class.const_get("#{profile.participant_type.to_s.classify}#{:Pending if profile.pending?}")
        render delegate_component.new(profile: profile)
      end

    private

      attr_reader :profile

      class NPQPending < Details; end
      class NPQ < Details; end
      class ECTPending < Details; end
      class MentorPending < Details; end
    end
  end
end
