# frozen_string_literal: true

module Admin::Participants
  class HistoryController < Admin::BaseController
    include RetrieveProfile
    include FindInductionRecords

    def show
      @latest_induction_record = latest_induction_record
      @historical_induction_records = historical_induction_records
    end
  end
end
