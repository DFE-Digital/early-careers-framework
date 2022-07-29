# frozen_string_literal: true

RSpec.describe Induction::ChangeInductionRecord do
  describe "#call" do
    let(:school_cohort) { create :school_cohort }
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }
    let(:ect_profile) { create(:ect_participant_profile, school_cohort:) }
    let(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }
    let(:mentor_profile_2) { create(:mentor_participant_profile, school_cohort:) }
    let!(:induction_record) { Induction::Enrol.call(induction_programme:, participant_profile: ect_profile, start_date: 6.months.ago, mentor_profile:) }
    let(:preferred_identity) { Identity::Create.call(user: ect_profile.user, email: "newemail@example.com") }
    let(:action_date) { 1.week.from_now }

    subject(:service) { described_class }

    it "adds a new induction record to the new programme for the participant" do
      expect {
        service.call(induction_record:,
                     changes: { mentor_profile: mentor_profile_2 })
      }.to change { ect_profile.induction_records.count }.by 1
    end

    it "creates a copy of the induction record with the specified changes" do
      service.call(induction_record:, changes: { preferred_identity: })
      current_record = ect_profile.current_induction_record
      expect(induction_record).to be_changed_induction_status
      expect(induction_record.end_date).to be_within(1.second).of Time.zone.now
      expect(current_record).to be_active_induction_status
      expect(current_record.training_status).to eq induction_record.training_status
      expect(current_record.start_date).to be_within(1.second).of Time.zone.now
      expect(current_record.end_date).to be_nil
      expect(current_record.mentor_profile).to eq induction_record.mentor_profile
      expect(current_record.induction_programme).to eq induction_record.induction_programme
      expect(current_record.participant_profile).to eq induction_record.participant_profile
      expect(current_record.preferred_identity).to eq preferred_identity
    end

    it "marks the previous induction record as changing" do
      service.call(induction_record:, changes: { mentor_profile: mentor_profile_2 })
      expect(induction_record).to be_changed_induction_status
    end

    context "when the induction record is leaving" do
      before do
        induction_record.leaving!(action_date)
      end

      it "preserves the induction_status on the new record" do
        service.call(induction_record:, changes: { mentor_profile: mentor_profile_2 })
        expect(ect_profile.current_induction_record).to be_leaving_induction_status
      end

      it "preserves the end_date on the new record" do
        service.call(induction_record:, changes: { mentor_profile: mentor_profile_2 })
        expect(ect_profile.current_induction_record.end_date).to be_within(1.second).of action_date
      end

      context "when it is a transfer out" do
        before do
          induction_record.update!(school_transfer: true)
        end

        it "moves the school_transfer flag to the new record" do
          service.call(induction_record:, changes: { mentor_profile: mentor_profile_2 })
          # FIXME: there is a bug in the categorisation / current scope that needs fixing - carded CST-881
          expect(ect_profile.induction_records.latest).to be_school_transfer
          expect(induction_record).not_to be_school_transfer
        end
      end
    end

    context "when the induction record start date is in the future" do
      before do
        induction_record.update!(start_date: 1.month.from_now)
      end

      it "does not add a new induction record" do
        expect {
          service.call(induction_record:,
                       changes: { mentor_profile: mentor_profile_2 })
        }.not_to change { ect_profile.induction_records.count }
      end

      it "updates the existing induction record" do
        service.call(induction_record:, changes: { mentor_profile: mentor_profile_2 })
        expect(induction_record.mentor_profile).to eq(mentor_profile_2)
      end
    end

    context "when the induction record is a school transfer" do
      context "when the start_date is in the past" do
        before do
          induction_record.update!(school_transfer: true)
          service.call(induction_record:, changes: { mentor_profile: mentor_profile_2 })
        end

        it "clears the school_transfer flag" do
          expect(ect_profile.current_induction_record).not_to be_school_transfer
        end
      end

      context "when the start_date is in the future" do
        before do
          induction_record.update!(school_transfer: true, start_date: 1.month.from_now)
          service.call(induction_record:, changes: { mentor_profile: mentor_profile_2 })
        end

        it "preserves the school_transfer flag" do
          expect(ect_profile.induction_records.latest).to be_school_transfer
        end
      end
    end

    context "when the induction record is withdrawn" do
      before do
        induction_record.training_status_withdrawn!
        service.call(induction_record:, changes: { mentor_profile: mentor_profile_2 })
      end

      it "preserves the training_status on the new record" do
        expect(ect_profile.current_induction_record).to be_training_status_withdrawn
      end
    end
  end
end
