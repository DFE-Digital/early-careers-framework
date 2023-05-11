# frozen_string_literal: true

module Admin::Participants
  class InductionRecordsController < Admin::BaseController
    include Pundit::Authorization
    include RetrieveProfile

    before_action :load_induction_record, only: %i[edit_preferred_email update_preferred_email]

    def show
      @participant_presenter = Admin::ParticipantPresenter.new(@participant_profile)

      add_breadcrumb(
        school.name,
        admin_school_participants_path(school),
      )
    end

    def edit_preferred_email
      authorize @induction_record

      @participant_identities = @participant_profile.user.participant_identities
    end

    def update_preferred_email
      authorize @induction_record

      if @induction_record.update(induction_params)
        set_success_message(heading: "The induction records has been updated")
        redirect_to admin_participant_induction_records_path(@participant_profile)
      else
        render "admin/participants/induction_records/edit_preferred_email"
      end
    end

  private

    def load_induction_record
      @induction_record = @participant_profile.induction_records.find(params[:induction_record_id])
    end

    def school
      @school ||= @participant_profile.school
    end

    def induction_params
      params.require(:induction_record).permit(:preferred_identity_id)
    end
  end
end
