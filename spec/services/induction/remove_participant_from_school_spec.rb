# frozen_string_literal: true

RSpec.describe Induction::RemoveParticipantFromSchool do
  describe "#call" do
    let(:induction_programme) { create(:induction_programme, :fip) }
    let(:school_cohort) { induction_programme.school_cohort }
    let(:school) { school_cohort.school }
    let(:ect_profile) { create(:ect_participant_profile, school_cohort:) }
    let(:mentor_profile_1) { create(:mentor_participant_profile, school_cohort:) }
    let(:mentor_profile_2) { create(:mentor_participant_profile, school_cohort:) }
    let(:sit_name) { "sit_full_name" }

    let(:participant_profile) { ect_profile }
    let(:mentor_profile) { mentor_profile_1 }
    let!(:induction_record) do
      Induction::Enrol.call(induction_programme:,
                            participant_profile: ect_profile,
                            start_date: 6.months.ago,
                            mentor_profile: mentor_profile_1)
    end

    before do
      Mentors::AddToSchool.call(mentor_profile: mentor_profile_1, school:)
      Mentors::AddToSchool.call(mentor_profile: mentor_profile_2, school:)
    end

    subject(:service) { described_class }

    it "withdraw the participant profile" do
      expect {
        service.call(participant_profile:, school:, sit_name:)
      }.to change { participant_profile.status }.from("active").to("withdrawn")
    end

    it "withdraw the induction record induction status" do
      expect {
        service.call(participant_profile:, school:, sit_name:)
      }.to change { induction_record.reload.induction_status }.from("active").to("withdrawn")
    end

    context "when the sit_name is not provided" do
      before do
        participant_profile.update!(request_for_details_sent_at: 70.days.ago)
      end

      it "do not notify the participant" do
        expect {
          service.call(participant_profile:)
        }.not_to have_enqueued_mail(ParticipantMailer, :participant_removed_by_sit)
      end
    end

    context "when the participant was not sent the email requesting for details" do
      it "do not notify the participant" do
        expect {
          service.call(participant_profile:, school:, sit_name:)
        }.not_to have_enqueued_mail(ParticipantMailer, :participant_removed_by_sit)
      end
    end

    context "when the sit is provided and the participant was sent the email requesting for details" do
      before do
        participant_profile.update!(request_for_details_sent_at: 70.days.ago)
      end

      it "notify the participant" do
        expect { service.call(participant_profile:, school:, sit_name:) }.to
        have_enqueued_mail(ParticipantMailer, :participant_removed_by_sit)
          .with(
            params: {
              participant_profile:, sit_name:
            },
            args: [],
          )
      end
    end

    context "when the participant is a mentor" do
      let(:participant_profile) { mentor_profile_1 }

      it "nullify all the mentorships of the mentor" do
        expect {
          service.call(participant_profile:, school:, sit_name:)
        }.to change { ect_profile.current_induction_record.mentor_profile_id }.from(participant_profile.id).to(nil)
      end

      it "remove the mentor from the school list" do
        expect {
          service.call(participant_profile:, school:, sit_name:)
        }.to change { SchoolMentor.count }.from(2).to(1)
      end
    end
  end
end
