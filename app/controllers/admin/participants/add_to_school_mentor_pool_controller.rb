# frozen_string_literal: true

module Admin::Participants
  class AddToSchoolMentorPoolController < Admin::BaseController
    include RetrieveProfile

    def new
      @add_mentor_to_school = Admin::Participants::AddMentorToSchoolForm.new(mentor_profile: @participant_profile)
    end

    def create
      @add_mentor_to_school = Admin::Participants::AddMentorToSchoolForm.new(mentor_profile: @participant_profile, school_urn: school_mentor_pool_params[:school_urn])

      if @add_mentor_to_school.save
        set_success_message content: "Mentor has been added to the school's mentor pool"
        redirect_to admin_participant_school_path(@participant_profile)
      else
        render :new
      end
    end

  private

    def school_mentor_pool_params
      params.require(:admin_participants_add_mentor_to_school_form).permit(:school_urn)
    end
  end
end
