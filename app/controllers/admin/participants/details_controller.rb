# frozen_string_literal: true

module Admin::Participants
  class DetailsController < Admin::BaseController
    include RetrieveProfile

    def show
      @participant_presenter = Admin::ParticipantPresenter.new(@participant_profile)

      add_breadcrumb(school.name, admin_school_participants_path(school)) if school.present?
    end

  private

    def school
      @school ||= @participant_profile.school
    end
  end
end
