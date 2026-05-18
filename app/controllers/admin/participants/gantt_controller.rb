# frozen_string_literal: true

module Admin::Participants
  class GanttController < Admin::BaseController
    include RetrieveProfile

    def show
      send_data(
        Participants::Gantt.new(
          induction_records(@participant_profile),
          declarations(@participant_profile),
          @participant_profile,
        ).to_png,
        type: "image/png",
      )
    end

  private

    def induction_records(participant_profile)
      InductionRecord.where(participant_profile:).order(created_at: "asc")
    end

    def declarations(participant_profile)
      ParticipantDeclaration.where(participant_profile:).order(created_at: "asc")
    end
  end
end
