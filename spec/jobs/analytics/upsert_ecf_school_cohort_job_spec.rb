# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::UpsertECFSchoolCohortJob do
  describe "#perform" do
    it "calls Analytics::ECFSchoolCohortService.upsert_record when the school cohort exists" do
      school_cohort = create(:school_cohort)
      expect(Analytics::ECFSchoolCohortService).to receive(:upsert_record).with(school_cohort)

      described_class.new.perform(school_cohort_id: school_cohort.id)
    end

    it "does not call Analytics::ECFSchoolCohortService.upsert_record when the school cohort does not exist" do
      expect(Analytics::ECFSchoolCohortService).not_to receive(:upsert_record)

      described_class.new.perform(school_cohort_id: SecureRandom.uuid)
    end
  end
end
