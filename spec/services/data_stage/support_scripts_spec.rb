# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataStage::SupportScripts do
  subject(:service) { described_class.new }
  let(:urn) { "123456" }
  let(:local_authority) { create(:local_authority, code: 10) }
  let(:local_authority_district) { create(:local_authority_district, code: "E123") }
  let!(:staged_school) { create(:staged_school, :closed, urn:, la_code: local_authority.code, administrative_district_code: local_authority_district.code) }
  let!(:closing_school) { create(:school, urn:, name: staged_school.name, school_status_code: 1, school_status_name: "open") }

  describe "#close_school_with_no_successor" do
    it "closes the live school" do
      service.close_school_with_no_successor(urn:)

      expect(closing_school.reload).to be_closed
    end

    context "when the school does not have a closed status" do
      let!(:staged_school) { create(:staged_school, urn:, la_code: local_authority.code, administrative_district_code: local_authority_district.code) }

      it "does not close the school" do
        service.close_school_with_no_successor(urn:)

        expect(closing_school.reload).to be_open
      end
    end

    context "when there is an induction coordinator" do
      let!(:induction_coordinator_profile) { create(:induction_coordinator_profile, schools: [closing_school]) }

      it "removes the link to the induction coordinator" do
        expect {
          service.close_school_with_no_successor(urn:)
        }.to change { InductionCoordinatorProfilesSchool.count }.by(-1).and not_change { InductionCoordinatorProfile.count }
      end
    end

    context "when there are participants" do
      let(:school_cohort) { create(:seed_school_cohort, :fip, :with_cohort, school: closing_school) }
      let(:induction_programme) { create(:seed_induction_programme, :fip, school_cohort:) }
      let(:ect_profile) { create(:ect_participant_profile, school_cohort:) }
      let(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }
      let!(:school_mentor) { create(:seed_school_mentor, school: closing_school, participant_profile: mentor_profile, preferred_identity: mentor_profile.participant_identity) }
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

  describe "#migrate_school_to_successor" do
    let(:successor_urn) { "987654" }
    let!(:new_staged_school) { create(:staged_school, urn: successor_urn, la_code: local_authority.code, administrative_district_code: local_authority_district.code) }
    let!(:new_school) { create(:school, urn: successor_urn, name: new_staged_school.name, school_status_code: new_staged_school.school_status_code, school_status_name: new_staged_school.school_status_name) }

    it "closes the live school" do
      service.migrate_school_to_successor(closing_urn: urn, successor_urn: successor_urn)

      expect(closing_school.reload).to be_closed
    end

    context "when the closing school does not have a closed status" do
      let!(:staged_school) { create(:staged_school, urn:, la_code: local_authority.code, administrative_district_code: local_authority_district.code) }

      it "does not close the school" do
        service.migrate_school_to_successor(closing_urn: urn, successor_urn: successor_urn)

        expect(closing_school.reload).to be_open
      end
    end

    context "when the successor school does not have an open status" do
      let!(:new_staged_school) { create(:staged_school, :proposed_to_open, urn: successor_urn, la_code: local_authority.code, administrative_district_code: local_authority_district.code) }

      it "does not migrate or close the school" do
        service.migrate_school_to_successor(closing_urn: urn, successor_urn: successor_urn)

        expect(closing_school.reload).to be_open
      end
    end

    context "when there is an induction coordinator but not on the new school" do
      let!(:induction_coordinator_profile) { create(:induction_coordinator_profile, schools: [closing_school]) }

      it "moves the induction coordinator to the new school" do
        service.migrate_school_to_successor(closing_urn: urn, successor_urn: successor_urn)

        expect(new_school.induction_coordinator_profiles.first).to eq induction_coordinator_profile
        expect(closing_school.induction_coordinator_profiles).to be_empty
      end
    end

    context "when there is an induction coordinator at both schools" do
      let!(:induction_coordinator_profile) { create(:induction_coordinator_profile, schools: [closing_school]) }
      let!(:induction_coordinator_profile_2) { create(:induction_coordinator_profile, schools: [new_school]) }

      it "removes the induction coordinator from the closing school" do
        service.migrate_school_to_successor(closing_urn: urn, successor_urn: successor_urn)

        expect(closing_school.induction_coordinator_profiles).to be_empty
      end

      it "does not add the induction coordinator to the new school" do
        service.migrate_school_to_successor(closing_urn: urn, successor_urn: successor_urn)

        expect(new_school.induction_coordinator_profiles).to match_array [induction_coordinator_profile_2]
      end
    end

    context "when there are participants" do
      let(:school_cohort) { create(:seed_school_cohort, :fip, :with_cohort, school: closing_school) }
      let(:partnership) { create(:partnership, cohort: school_cohort.cohort, school: closing_school) }
      let(:induction_programme) { create(:seed_induction_programme, :fip, school_cohort:, partnership:) }
      let(:ect_profile) { create(:ect_participant_profile, school_cohort:) }
      let(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }
      let!(:school_mentor) { create(:seed_school_mentor, school: closing_school, participant_profile: mentor_profile, preferred_identity: mentor_profile.participant_identity) }
      let!(:ect_induction_record) { create(:seed_induction_record, :with_schedule, participant_profile: ect_profile, induction_programme:) }
      let!(:mentor_induction_record) { create(:seed_induction_record, :with_schedule, participant_profile: mentor_profile, induction_programme:) }

      it "moves them to the new school" do
        service.migrate_school_to_successor(closing_urn: urn, successor_urn: successor_urn)

        expect(ect_profile.latest_induction_record.school).to eq new_school
        expect(mentor_profile.latest_induction_record.school).to eq new_school
      end

      it "moves school mentor records to the new school" do
        service.migrate_school_to_successor(closing_urn: urn, successor_urn: successor_urn)
        expect(school_mentor.reload.school).to eq new_school
      end

      context "when there is no matching school_cohort" do
        it "moves the school_cohort from the closing school" do
          service.migrate_school_to_successor(closing_urn: urn, successor_urn: successor_urn)
          expect(school_cohort.reload.school).to eq new_school
        end

        it "moves the partnership to the new school" do
          service.migrate_school_to_successor(closing_urn: urn, successor_urn: successor_urn)
          expect(partnership.reload.school).to eq new_school
          expect(partnership.relationship).to be false
        end
      end

      context "when there is a matching school_cohort and programme" do
        let(:new_school_cohort) { create(:seed_school_cohort, :fip, cohort: school_cohort.cohort, school: new_school) }
        let(:new_partnership) { partnership.dup.tap { |part| part.update!(school: new_school) } }
        let!(:new_induction_programme) { create(:seed_induction_programme, :fip, school_cohort: new_school_cohort, partnership: new_partnership) }

        it "moves the participants to the new programme" do
          service.migrate_school_to_successor(closing_urn: urn, successor_urn: successor_urn)
          expect(ect_profile.latest_induction_record.induction_programme).to eq new_induction_programme
          expect(mentor_profile.latest_induction_record.induction_programme).to eq new_induction_programme
        end

        it "doesn't move the original programme" do
          service.migrate_school_to_successor(closing_urn: urn, successor_urn: successor_urn)
          expect(induction_programme.school_cohort.school).to eq closing_school
        end

        it "doesn't move the original partnership" do
          service.migrate_school_to_successor(closing_urn: urn, successor_urn: successor_urn)
          expect(partnership.reload.school).to eq closing_school
        end
      end

      context "when there is a matching school_cohort but different programme" do
        let!(:new_school_cohort) { create(:seed_school_cohort, :fip, cohort: school_cohort.cohort, school: new_school) }
        let(:new_partnership) { create(:partnership, cohort: school_cohort.cohort, school: new_school) }
        let!(:new_induction_programme) { create(:seed_induction_programme, :fip, school_cohort: new_school_cohort, partnership: new_partnership) }

        it "moves the entire programme the new school" do
          service.migrate_school_to_successor(closing_urn: urn, successor_urn: successor_urn)
          expect(induction_programme.reload.school_cohort.school).to eq new_school
          expect(ect_profile.latest_induction_record.induction_programme).to eq induction_programme
          expect(mentor_profile.latest_induction_record.induction_programme).to eq induction_programme
          expect(induction_programme.partnership.school).to eq new_school
          expect(induction_programme.partnership.relationship).to be true
        end
      end
    end

    context "when there are unprocessed school change records" do
      let!(:school_change) { create(:staged_school_change, :closing, school: staged_school) }

      it "marks the change as handled" do
        service.migrate_school_to_successor(closing_urn: urn, successor_urn: successor_urn)
        expect(school_change.reload).to be_handled
      end
    end
  end
end
