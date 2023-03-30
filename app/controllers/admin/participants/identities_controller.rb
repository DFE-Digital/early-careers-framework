# frozen_string_literal: true

module Admin::Participants
  class IdentitiesController < Admin::BaseController
    include RetrieveProfile

    def show
      @participant_identities = @participant_profile.user.participant_identities

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
