# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataStage::SupportScripts do
  subject(:service) { described_class.new }
  let(:urn) { "123456" }
  let(:local_authority) { create(:local_authority, code: 10) }
  let(:local_authority_district) { create(:local_authority_district, code: "E123") }
  let!(:staged_school) { create(:staged_school, :closed, urn:, la_code: local_authority.code, administrative_district_code: local_authority_district.code) }
  let!(:live_school) { create(:school, urn:, name: staged_school.name, school_status_code: 1, school_status_name: "open") }

  describe "#close_school_with_no_successor" do
    it "closes the live school" do
      service.close_school_with_no_successor(urn:)

      expect(live_school.reload).to be_closed
    end

    context "when there is an induction coordinator" do
      let!(:induction_coordinator_profile) { create(:induction_coordinator_profile, schools: [live_school]) }

      it "removes the link to the induction coordinator" do
        expect {
          service.close_school_with_no_successor(urn:)
        }.to change { InductionCoordinatorProfilesSchool.count }.by(-1).and not_change { InductionCoordinatorProfile.count }
      end
    end

    context "when there are participants" do
      let(:school_cohort) { create(:seed_school_cohort, :fip, :with_cohort, school: live_school) }
      let(:induction_programme) { create(:seed_induction_programme, :fip, school_cohort:) }
      let(:ect_profile) { create(:ect_participant_profile, school_cohort:) }
      let(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }
      let!(:school_mentor) { create(:seed_school_mentor, school: live_school, participant_profile: mentor_profile, preferred_identity: mentor_profile.participant_identity) }
      let!(:ect_induction_record) { create(:seed_induction_record, :with_schedule, participant_profile: ect_profile, induction_programme:) }
      let!(:mentor_induction_record) { create(:seed_induction_record, :with_schedule, participant_profile: mentor_profile, induction_programme:) }

      it "marks them as leaving the school" do
        service.close_school_with_no_successor(urn:)

        expect(ect_induction_record.reload).to be_leaving_induction_status
        expect(mentor_induction_record.reload).to be_leaving_induction_status
      end

      it "removes school mentor records" do
        expect {
          service.close_school_with_no_successor(urn:)
        }.to change { SchoolMentor.count }.by(-1).and not_change { ParticipantProfile.count }
      end
    end

    context "when there are unprocessed school change records" do
      let!(:school_change) { create(:staged_school_change, :closing, school: staged_school) }

      it "marks the change as handled" do
        service.close_school_with_no_successor(urn:)
        expect(school_change.reload).to be_handled
      end
    end
  end
end
