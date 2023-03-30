# frozen_string_literal: true

module Admin::Participants
  class DeclarationHistoryController < Admin::BaseController
    include RetrieveProfile

    def show
      @participant_declarations = @participant_profile.participant_declarations
                                                      .includes(:cpd_lead_provider, :delivery_partner)
                                                      .order(created_at: :desc)

      add_breadcrumb(
        school.name,
        admin_school_participants_path(school),
      )
    end

  private

    def school
      @school ||= @participant_profile.school
    end
  end
end
