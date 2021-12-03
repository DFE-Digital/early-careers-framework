# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  class ECT < ECF
    belongs_to :mentor_profile, class_name: "Mentor", optional: true
    has_one :mentor, through: :mentor_profile, source: :user

    def ect?
      true
    end

    def participant_type
      :ect
    end
  end
end
