# frozen_string_literal: true

RSpec.describe Induction::ChangeMentor do
  describe "#call" do
    let(:school_cohort) { create :school_cohort }
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }
    let(:ect_profile) { create(:ect_participant_profile, school_cohort:) }
    let(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }
    let(:mentor_profile_2) { create(:mentor_participant_profile, school_cohort:) }
    let!(:induction_record) { Induction::Enrol.call(induction_programme:, participant_profile: ect_profile, start_date: 6.months.ago, mentor_profile:) }

    subject(:service) { described_class }

    it "adds a new induction record to the new programme for the participant" do
      expect {
        service.call(induction_record:,
                     mentor_profile: mentor_profile_2)
      }.to change { ect_profile.induction_records.count }.by 1
    end

    it "sets the mentor_profile to the correct value" do
      service.call(induction_record:, mentor_profile: mentor_profile_2)
      expect(ect_profile.current_induction_record.mentor_profile).to eq mentor_profile_2
    end

    it "touches the mentor user" do
      expect {
        service.call(induction_record:, mentor_profile: mentor_profile_2)
      }.to change(mentor_profile_2.user, :updated_at)
    end

    it "does not send material email" do
      allow(MentorMailer).to receive(:with).and_call_original

      service.call(induction_record:, mentor_profile: mentor_profile_2)

      expect(MentorMailer).not_to have_received(:with)
    end

    context "with CIP induction programme" do
      let!(:sit) { create(:induction_coordinator_profile, schools: [induction_record.school]).user }
      context "with SIT" do
        let(:induction_programme) { create(:induction_programme, :cip, school_cohort:) }

        it "sends the email" do
          allow(MentorMailer).to receive(:with).and_call_original

          service.call(induction_record:, mentor_profile: mentor_profile_2)

          expect(MentorMailer).to have_received(:with).with({
            ect_name: ect_profile.user.full_name,
            sit_name: sit.full_name,
            mentor_profile: mentor_profile_2,
            cip_materials_name: induction_record.induction_programme.core_induction_programme.name,
          })
        end
      end

      context "without SIT" do
        it "does not send material email" do
          allow(MentorMailer).to receive(:with).and_call_original

          service.call(induction_record:, mentor_profile: mentor_profile_2)

          expect(MentorMailer).not_to have_received(:with)
        end
      end
    end
  end
end
