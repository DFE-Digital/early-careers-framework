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

    describe "sending training materials" do
      let(:cip_school_cohort) { create :school_cohort, :cip }
      let(:fip_school_cohort) { create :school_cohort, :fip }
      let(:materials_1) { "1" }
      let(:materials_2) { "2" }

      let!(:sit) { create(:induction_coordinator_profile, schools: [induction_record.school]).user }

      context "the mentor is at a CIP school and the ECT is at a CIP school" do
        context "with same training materials" do
          let(:school_cohort_1) do
            create(
              :school_cohort,
              :cip,
              default_induction_programme: create(
                :induction_programme,
                :cip,
                core_induction_programme: create(
                  :core_induction_programme,
                  name: materials_1,
                ),
              ),
            )
          end

          let(:school_cohort_2) do
            create(
              :school_cohort,
              :cip,
              default_induction_programme: create(
                :induction_programme,
                :cip,
                core_induction_programme: create(
                  :core_induction_programme,
                  name: materials_1,
                ),
              ),
            )
          end

          let!(:ect_profile) { create(:ect_participant_profile, school_cohort: school_cohort_1) }
          let!(:mentor_profile_2) { create(:mentor_participant_profile, school_cohort: school_cohort_2) }

          it "does not send the email" do
            allow(MentorMailer).to receive(:with).and_call_original

            service.call(induction_record:, mentor_profile: mentor_profile_2)

            expect(MentorMailer).not_to have_received(:with)
          end
        end

        context "with different training materials" do
          let(:school_cohort_1) do
            create(
              :school_cohort,
              :cip,
              default_induction_programme: create(
                :induction_programme,
                :cip,
                core_induction_programme: create(
                  :core_induction_programme,
                  name: materials_1,
                ),
              ),
            )
          end

          let(:school_cohort_2) do
            create(
              :school_cohort,
              :cip,
              default_induction_programme: create(
                :induction_programme,
                :cip,
                core_induction_programme: create(
                  :core_induction_programme,
                  name: materials_2,
                ),
              ),
            )
          end

          let!(:ect_profile) { create(:ect_participant_profile, school_cohort: school_cohort_1) }
          let!(:mentor_profile_2) { create(:mentor_participant_profile, school_cohort: school_cohort_2) }

          it "sends the email" do
            allow(MentorMailer).to receive(:with).and_call_original

            service.call(induction_record:, mentor_profile: mentor_profile_2)

            expect(MentorMailer).to have_received(:with).with({
              ect_name: ect_profile.user.full_name,
              sit_name: sit.full_name,
              lead_provider_name: induction_record.lead_provider.name,
              mentor_email: mentor_profile_2.user.email,
              mentor_name: mentor_profile_2.user.full_name,
              school_name: induction_record.school.name,
            })
          end
        end
      end

      context "the mentor is at a FIP school and the ECT is at a CIP school" do
        let(:ect_profile) { create(:ect_participant_profile, school_cohort: cip_school_cohort) }
        let(:mentor_profile_2) { create(:mentor_participant_profile, school_cohort: fip_school_cohort) }

        it "sends the email" do
          allow(MentorMailer).to receive(:with).and_call_original

          service.call(induction_record:, mentor_profile: mentor_profile_2)

          expect(MentorMailer).to have_received(:with).with({
            ect_name: ect_profile.user.full_name,
            sit_name: sit.full_name,
            lead_provider_name: induction_record.lead_provider.name,
            mentor_email: mentor_profile_2.user.email,
            mentor_name: mentor_profile_2.user.full_name,
            school_name: induction_record.school.name,
          })
        end
      end
    end
  end
end
