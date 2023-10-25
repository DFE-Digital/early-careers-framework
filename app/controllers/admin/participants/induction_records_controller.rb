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
        flash.now[:alert] = "The induction records could not be updated"
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
#
# r = Hash.new { 0 }
# i = 0
# ParticipantProfile::ECT.where(induction_start_date: nil).find_each do |pp|
#   i += 1
#   lir = pp.latest_induction_record
#   cohort = lir&.cohort_start_year
#   if cohort
#     r["#{cohort}-#{lir.induction_status}-#{lir.training_status}"] += 1 if cohort
#   else
#     pp pp.id
#   end
# end
# r
# - Total ECTs: 4555
#
# - ECTs by cohort:
# {
#   2023 => 2162,
#   2022 => 993,
#   2021 => 1376,
#   2020 => 24
# }
#
# - ECTs by cohort-induction_status-training_status:
# {
#   "2020-active-active" => 23,
#   "2020-withdrawn-active" => 1,
#   "2021-active-active" => 277,
#   "2021-active-deferred" => 26,
#   "2021-active-withdrawn" => 195,
#   "2021-leaving-active" => 36,
#   "2021-leaving-deferred" => 2,
#   "2021-leaving-withdrawn" => 33,
#   "2021-withdrawn-active" => 803,
#   "2021-withdrawn-deferred" => 1,
#   "2021-withdrawn-withdrawn" => 3,
#   "2022-active-active" => 484,
#   "2022-active-deferred" => 34,
#   "2022-active-withdrawn" => 70,
#   "2022-leaving-active" => 44,
#   "2022-leaving-deferred" => 5,
#   "2022-leaving-withdrawn" => 13,
#   "2022-withdrawn-active" => 340,
#   "2022-withdrawn-deferred" => 2,
#   "2022-withdrawn-withdrawn" => 1,
#   "2023-active-active" => 2115,
#   "2023-active-deferred" => 2,
#   "2023-active-withdrawn" => 21,
#   "2023-leaving-active" => 7,
#   "2023-leaving-withdrawn" => 1,
#   "2023-withdrawn-active" => 16
# }
#
# # {2023=>14157, 2022=>27489, 2021=>38247, 2020=>24}
