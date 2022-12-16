# frozen_string_literal: true

module Admin::Participants
  class DetailsController < Admin::BaseController
    include RetrieveProfile
    include FindInductionRecords

    def show
      @latest_induction_record = latest_induction_record
    end
  end
end
