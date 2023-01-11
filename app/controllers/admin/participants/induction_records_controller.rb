# frozen_string_literal: true

module Admin::Participants
  class InductionRecordsController < Admin::BaseController
    include RetrieveProfile
    include FindInductionRecords

    def show
      @all_induction_records = all_induction_records
    end
  end
end
