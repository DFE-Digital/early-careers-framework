# frozen_string_literal: true

# TODO: needs refactoring for new wizard form
RSpec.describe Schools::AddParticipants::AddWizard, type: :model do
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:current_step) { :email }
  let(:data_store) { instance_double(FormData::AddParticipantStore) }
  let(:school) { create(:seed_school, :with_induction_coordinator) }
  let(:school_cohort) { create(:seed_school_cohort, :fip, cohort:, school:) }
  let!(:induction_programme) { create(:seed_induction_programme, :fip, :with_partnership, school_cohort:, school:, cohort:) }
  let(:sit_user) { school.induction_coordinators.first }
  let(:submitted_params) { {} }

  subject(:wizard) { described_class.new(current_step:, data_store:, current_user: sit_user, school:, submitted_params:) }

  before do
    allow(data_store).to receive(:store).and_return({ something: "is here" })
    allow(data_store).to receive(:current_user).and_return(sit_user)
    allow(data_store).to receive(:school_id).and_return(school.slug)
    allow(data_store).to receive(:set)
  end

  describe "email_in_use?" do
    let(:ect_mentor) { false }
    let(:transfer) { false }
    let(:confirmed_trn) { "0012345" }

    before do
      allow(data_store).to receive(:email).and_return("ray.clemence@example.com")
      allow(data_store).to receive(:ect_mentor?).and_return(ect_mentor)
      allow(data_store).to receive(:transfer?).and_return(transfer)
      allow(data_store).to receive(:confirmed_trn).and_return(confirmed_trn)
    end

    context "when the email is not already in use" do
      it "returns false" do
        expect(wizard).not_to be_email_in_use
      end
    end

    context "when the email is in use by an ECF user" do
      let(:user) { create(:user, email: "ray.clemence@example.com") }
      let(:teacher_profile) { create(:teacher_profile, user:, trn: confirmed_trn) }
      let!(:ect_profile) { create(:ect_participant_profile, teacher_profile:) }

      it "returns true" do
        expect(wizard).to be_email_in_use
      end

      context "when adding a mentor profile to an ECT" do
        let(:ect_mentor) { true }

        it "returns false" do
          expect(wizard).not_to be_email_in_use
        end

        context "when the email owner is different ECF participant" do
          let(:user) { create(:seed_user, email: "nigel.martyn@example.com") }
          let(:email_owner) { create(:seed_user, email: "ray.clemence@example.com") }
          let(:owner_teacher_profile) { create(:seed_teacher_profile, user: email_owner, trn: "1234567") }
          let!(:owner_profile) { create(:ect_participant_profile, teacher_profile: owner_teacher_profile) }

          it "returns true" do
            expect(wizard).to be_email_in_use
          end
        end
      end

      context "when the profile record is withdrawn" do
        let!(:ect_profile) { create(:ect_participant_profile, :withdrawn_record, teacher_profile:) }

        it "returns false" do
          expect(wizard).not_to be_email_in_use
        end
      end
    end

    context "when the email is in use by a NPQ registrant", :with_default_schedules do
      let(:user) { create(:user, email: "ray.clemence@example.com") }
      let(:teacher_profile) { create(:teacher_profile, user:) }
      let!(:npq_profile) { create(:npq_participant_profile, teacher_profile:) }

      it "returns false" do
        expect(wizard).not_to be_email_in_use
      end
    end
  end
end
