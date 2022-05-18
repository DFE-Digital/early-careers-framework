# frozen_string_literal: true

module Finance
  module Participants
    module ProfilesHelper
      def training_status_select_options
        ParticipantProfile.training_statuses.keys.map do |status|
          OpenStruct.new(value: status, label: status.titleize)
        end
      end
    end
  end
end
