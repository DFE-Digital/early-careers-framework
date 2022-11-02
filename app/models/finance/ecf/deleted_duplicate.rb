# frozen_string_literal: true

module Finance
  module ECF
    class DeletedDuplicate < ApplicationRecord
      belongs_to :primary_participant_profile, class_name: "ParticipantProfile"
    end
  end
end
