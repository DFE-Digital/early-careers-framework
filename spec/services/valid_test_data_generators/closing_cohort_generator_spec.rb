# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValidTestDataGenerators::ClosingCohortGenerator do
  let(:cohort) { create(:cohort, start_year: described_class::COHORT_TO_CLOSE) }
  let(:cpd_lead_provider) { lead_provider.cpd_lead_provider }
  let(:lead_provider) { create(:lead_provider) }
  let(:schedules) { Finance::Schedule.where(schedule_identifier: described_class::SCHEDULE_IDENTIFIERS, cohort:) }

  let(:instance) { described_class.new(name: lead_provider.name, cohort:) }

  describe "#call" do
    let(:number) { 1 }
    let(:number_created_per_type) { 2 }
    subject(:generate) { instance.call(number:) }

    before do
      create(:local_authority)
      create(:partnership, cohort:, lead_provider:)
      create(:ecf_statement, :next_output_fee, cpd_lead_provider:, cohort:)
    end

    it { expect(schedules.count).to be >= 0 }
    it { expect { generate }.to change { cohort.payments_frozen_at }.from(nil).to(be_within(5.seconds).of(Time.zone.now)) }
    it { expect { generate }.to change(ParticipantProfile::ECT, :count).by((number * number_created_per_type) * schedules.count) }
    it { expect { generate }.to change(ParticipantProfile::Mentor, :count).by((number * number_created_per_type) * schedules.count) }

    it "creates a partially trained ECT that is migrated to the 2024 cohort" do
      generate

      created_ect = ParticipantProfile::ECT.order(created_at: :asc).first

      expect(created_ect).to be_cohort_changed_after_payments_frozen
      expect(created_ect.induction_completion_date).to be_nil

      expect(created_ect.participant_declarations).to be_present
      expect(created_ect.participant_declarations.map(&:cohort)).to all(eq(cohort))

      expect(created_ect.latest_induction_record.cohort).to eq(Cohort.find_by(start_year: 2024))
    end

    it "creates a completed ECT that is not migrated to the 2024 cohort" do
      generate

      created_ect = ParticipantProfile::ECT.order(created_at: :asc).last

      expect(created_ect).not_to be_cohort_changed_after_payments_frozen
      expect(created_ect.induction_completion_date).to be_present

      expect(created_ect.participant_declarations).to be_present
      expect(created_ect.participant_declarations.map(&:declaration_type)).to match_array(described_class::ECT_DECLARATION_TYPES)
      expect(created_ect.participant_declarations.map(&:cohort)).to all(eq(cohort))

      expect(created_ect.latest_induction_record.cohort).to eq(cohort)
    end

    it "creates a partially trained mentor that is not migrated to the 2024 cohort" do
      generate

      created_mentor = ParticipantProfile::Mentor.order(created_at: :asc).first

      expect(created_mentor).not_to be_cohort_changed_after_payments_frozen
      expect(created_mentor.mentor_completion_date).to be_present
      expect(created_mentor.mentor_completion_reason).to be_present

      expect(created_mentor.participant_declarations).to be_present
      expect(created_mentor.participant_declarations.map(&:cohort)).to all(eq(cohort))

      expect(created_mentor.latest_induction_record.cohort).to eq(cohort)
    end

    it "creates a completed mentor that is not migrated to the 2024 cohort" do
      generate

      created_mentor = ParticipantProfile::Mentor.order(created_at: :asc).last

      expect(created_mentor).not_to be_cohort_changed_after_payments_frozen
      expect(created_mentor.mentor_completion_date).to be_present
      expect(created_mentor.mentor_completion_reason).to be_present

      expect(created_mentor.participant_declarations).to be_present
      expect(created_mentor.participant_declarations.map(&:declaration_type)).to match_array(described_class::MENTOR_DECLARATION_TYPES)
      expect(created_mentor.participant_declarations.map(&:cohort)).to all(eq(cohort))

      expect(created_mentor.latest_induction_record.cohort).to eq(cohort)
    end

    context "when creating multiple participants" do
      let(:number) { 5 }

      it { expect { generate }.to change(ParticipantProfile::ECT, :count).by((number * number_created_per_type) * schedules.count) }
      it { expect { generate }.to change(ParticipantProfile::Mentor, :count).by((number * number_created_per_type) * schedules.count) }
    end

    context "when attempting to close a different cohort" do
      let(:cohort) { create(:cohort, start_year: described_class::COHORT_TO_CLOSE + 1) }

      it { expect { generate }.not_to change { cohort.payments_frozen_at } }
      it { expect { generate }.not_to change(ParticipantProfile, :count) }
    end
  end
end
