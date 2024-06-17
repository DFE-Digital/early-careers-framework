# frozen_string_literal: true

RSpec.describe Induction::Enrol do
  shared_examples "creates a new active participant_profile_state record" do
    it "creates a new participant_profile_state record with active state" do
      expect { subject.call(participant_profile:, induction_programme:) }.to change { ParticipantProfileState.count }.by(1)
      expect(participant_profile.reload.participant_profile_state.state).to eql("active")
    end
  end

  describe "#call" do
    let(:school_cohort) { create :school_cohort, appropriate_body: create(:appropriate_body_local_authority) }
    let!(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }
    let(:teacher_profile) { create(:teacher_profile) }
    let(:participant_profile) { create(:ect_participant_profile, teacher_profile:, school_cohort:) }

    subject(:service) { described_class }

    it "creates an induction record for the given programme" do
      expect { service.call(participant_profile:, induction_programme:) }.to change { induction_programme.induction_records.count }.by 1
    end

    it_behaves_like "creates a new active participant_profile_state record"

    context "when the participant has completed induction" do
      subject { described_class.call(participant_profile:, induction_programme:) }

      before do
        participant_profile.update!(induction_completion_date: 2.days.ago)
      end

      it "do not create a new participant_profile_state record" do
        expect { subject }.to not_change(ParticipantProfileState, :count)
                                .and not_change(participant_profile, :training_status)
                                       .and not_change(participant_profile, :status)
      end

      it { is_expected.to be_completed_induction_status }
    end

    context "when a participant_profile_state already exists" do
      let(:cpd_lead_provider_id) { induction_programme.lead_provider&.cpd_lead_provider_id }
      let!(:existing_participant_profile_state) { create(:participant_profile_state, participant_profile:, state: existing_state, cpd_lead_provider_id:) }

      context "when the state is active" do
        let(:existing_state) { :active }

        context "when enroling to a programme with the same cpd lead provider" do
          it "does not create a duplicate record" do
            expect { subject.call(participant_profile:, induction_programme:) }.to change { ParticipantProfileState.count }.by(0)
          end
        end

        context "when enroling to a programme with a different cpd lead provider" do
          let(:cpd_lead_provider_id) { "1234" }

          it_behaves_like "creates a new active participant_profile_state record"
        end
      end

      context "when the state is not active" do
        let(:existing_state) { :withdrawn }

        it_behaves_like "creates a new active participant_profile_state record"
      end
    end

    context "when the participant profile training_status is withdrawn" do
      let(:participant_profile) { create(:ect_participant_profile, training_status: :withdrawn, status: :withdrawn) }

      it "it changes it to active" do
        service.call(participant_profile:, induction_programme:)
        expect(participant_profile.training_status).to eql "active"
        expect(participant_profile.status).to eql "active"
      end
    end

    context "without optional params" do
      let(:induction_record) do
        service.call(participant_profile:, induction_programme:)
      end

      it "sets the start_date to the schedule start_date" do
        expect(induction_record.start_date).to eq(participant_profile.schedule.milestones.first.start_date)
      end

      it "sets the preferred identity to be the participant_profile.participant_identity" do
        expect(induction_record.preferred_identity_id).to eq(participant_profile.participant_identity_id)
      end

      it "sets the appropriate body the default one from the school cohort of the induction programme" do
        expect(induction_record.appropriate_body_id).to eq(school_cohort.appropriate_body_id)
      end
    end

    context "when a mentor_profile is provided" do
      let(:mentor_profile) { create(:mentor_participant_profile) }

      let(:induction_record) do
        service.call(participant_profile:,
                     induction_programme:,
                     mentor_profile:)
      end

      it "sets the mentor for the participant" do
        expect(induction_record.mentor_profile).to eq mentor_profile
      end
    end

    context "when a start_date is provided" do
      let(:start_date) { 1.week.from_now }
      let(:induction_record) do
        service.call(participant_profile:,
                     induction_programme:,
                     start_date:)
      end

      it "sets the start_date" do
        expect(induction_record.start_date).to be_within(1.second).of(start_date)
      end
    end

    context "when a schedule is provided" do
      let(:schedule) { Finance::Schedule::ECF.first }
      let(:induction_record) do
        service.call(participant_profile:,
                     induction_programme:,
                     schedule:)
      end

      it "sets the schedule" do
        expect(induction_record.schedule).to eq(schedule)
      end
    end

    context "when a preferred email is provided" do
      let(:preferred_email) { "newemail@example.com" }

      let(:induction_record) do
        service.call(participant_profile:,
                     induction_programme:,
                     preferred_email:)
      end

      it "adds a new identity to the user" do
        expect { induction_record }.to change { participant_profile.participant_identity.user.participant_identities.count }.by 1
      end

      it "sets the preferred identity" do
        expect(induction_record.preferred_identity.email).to eq(preferred_email)
      end
    end
  end
end
