# frozen_string_literal: true

module Admin::Participants
  class InductionRecordsController < Admin::BaseController
    include Pundit::Authorization
    include RetrieveProfile

    before_action :load_induction_record, except: %i[show]

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

    def edit_training_status
      authorize @induction_record
    end

    def update_training_status
      authorize @induction_record

      if training_status_updated?
        set_success_message(heading: "The induction records has been updated")
        redirect_to admin_participant_induction_records_path(@participant_profile)
      else
        flash.now[:notice] = { heading: "The induction records could not be updated" }
        render "admin/participants/induction_records/edit_training_status"
      end
    end

  private

    def load_induction_record
      @induction_record = @participant_profile.induction_records.find(params[:induction_record_id])
    end

    # Get the school from the induction record for ECTs and from the participant profile for NPQs
    def school
      @school ||= @participant_profile.latest_induction_record&.school || @participant_profile.school
    end

    def induction_params
      params.require(:induction_record).permit(:preferred_identity_id)
    end

    def training_status_params
      params.require(:induction_record).permit(:training_status)
    end

    def training_status_updated?
      return true if @induction_record.attributes.slice(*training_status_params.keys) == training_status_params

      begin
        ActiveRecord::Base.transaction do
          @participant_profile.update!(training_status_params) if @induction_record == @participant_profile.latest_induction_record
          Induction::ChangeInductionRecord.call(induction_record: @induction_record, changes: training_status_params)

          true
        end
      rescue StandardError
        false
      end
    end
  end
end
