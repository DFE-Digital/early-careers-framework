# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::SchoolTransferForm, type: :model do
  subject(:form) { described_class.new(participant_profile_id: participant_profile.id) }
  let(:participant_profile) { create :ect_participant_profile }
  let(:cohort) { participant_profile.schedule.cohort }
  let(:induction_programme) { create(:induction_programme, :cip) }
  let!(:induction_record) { Induction::Enrol.call(participant_profile:, induction_programme:, start_date: 1.day.ago) }

  describe "#perform_transfer!" do
    let(:school_cohort) { create(:school_cohort, :fip, :with_induction_programme, cohort:) }
    let(:school) { school_cohort.school }
    let(:induction_programme_2) { school_cohort.induction_programmes.first }
    let(:transfer_choice) { induction_programme_2.id }

    before do
      school_cohort.update!(default_induction_programme: induction_programme_2)
      form.new_school_urn = school.urn
      form.start_date = 10.days.from_now
      form.email = "ted.jones@example.com"
      form.transfer_choice = transfer_choice
    end

    it "adds a new induction record" do
      expect { form.perform_transfer! }.to change { participant_profile.induction_records.count }.by(1)
    end

    it "enrols the participant in the selected programme" do
      form.perform_transfer!
      expect(participant_profile.induction_records.latest.induction_programme).to eq induction_programme_2
    end

    context "when continuing current programme" do
      let(:transfer_choice) { "continue" }

      before do
        form.new_school_urn = school.urn
        form.start_date = 10.days.from_now
        form.email = "ted.jones@example.com"
        form.transfer_choice = "continue"
      end

      it "adds a new programme to the school cohort" do
        expect { form.perform_transfer! }.to change { school_cohort.induction_programmes.core_induction_programme.count }.by(1)
      end

      it "enrols the participant in the selected programme" do
        form.perform_transfer!
        expect(participant_profile.induction_records.latest.induction_programme).to eq school_cohort.induction_programmes.order(:created_at).last
      end

      context "when a matching programme already exists" do
        let!(:matching_programme) { create(:induction_programme, :cip, school_cohort:, core_induction_programme: induction_programme.core_induction_programme) }
        it "does not create a new programme" do
          expect { form.perform_transfer! }.not_to change { school_cohort.induction_programmes.count }
        end

        it "enrols the participant in the matching programme" do
          form.perform_transfer!
          expect(participant_profile.induction_records.latest.induction_programme).to eq matching_programme
        end
      end

      context "when there is no school cohort at the school" do
        let(:school) { create(:school) }

        it "creates a new school cohort" do
          expect { form.perform_transfer! }.to change { school.school_cohorts.count }.by(1)
        end

        it "sets the induction programme choice on the school cohort" do
          form.perform_transfer!
          expect(school.school_cohorts.first).to be_core_induction_programme
        end

        it "sets the default induction programme on the school cohort to be the new programme" do
          form.perform_transfer!
          expect(school.school_cohorts.first.default_induction_programme).to eq school.school_cohorts.first.induction_programmes.first
        end
      end
    end
  end

  describe "#skip_transfer_options?" do
    let(:school) { create(:school) }

    before do
      form.new_school_urn = school.urn
    end

    context "when the destination school has more than one programme in the cohort" do
      let(:school_cohort) { create(:school_cohort, :cip, :with_induction_programme, core_induction_programme: induction_programme.core_induction_programme, school:, cohort:) }
      let!(:induction_programme_2) { create(:induction_programme, :fip, school_cohort:) }

      it "returns false" do
        expect(form.skip_transfer_options?).to be false
      end
    end

    context "when the destination school has a different programme in the cohort" do
      let!(:school_cohort) { create(:school_cohort, :fip, :with_induction_programme, school:, cohort:) }

      it "returns false" do
        expect(form.skip_transfer_options?).to be false
      end
    end

    context "when there is no school cohort at the destination school" do
      it "returns true" do
        expect(form.skip_transfer_options?).to be true
      end
    end

    context "when there is a single programme at the destination school" do
      let!(:school_cohort) { create(:school_cohort, :cip, :with_induction_programme, core_induction_programme: induction_programme.core_induction_programme, school:, cohort:) }

      context "when the programme matches the participants induction programme" do
        it "returns true" do
          expect(form.skip_transfer_options?).to be true
        end
      end

      context "when the participant does not have an induction record" do
        let!(:induction_record) { nil }

        it "returns true" do
          expect(form.skip_transfer_options?).to be true
        end
      end
    end
  end

  describe "attributes" do
    let(:attributes) do
      {
        new_school_urn: "123456",
        start_date: 1.day.ago.to_date,
        email: "tester@example.com",
        transfer_choice: "continue",
      }
    end

    it "returns a hash of attributes" do
      form.assign_attributes(attributes)
      expect(form.attributes).to include attributes
    end
  end

  describe "validations" do
    context "when :select_school step" do
      it { is_expected.to validate_presence_of(:new_school_urn).on(:select_school) }

      it "checks that the new school exists" do
        form.new_school_urn = "909012"
        expect(form.valid?(:select_school)).to be false
        expect(form.errors[:new_school_urn]).to be_present

        school = create(:school, urn: "123456")
        form.new_school_urn = school.urn
        expect(form.valid?(:select_school)).to be true
      end

      it "checks the urn provided is from a new school" do
        form.new_school_urn = participant_profile.school.urn
        expect(form.valid?(:select_school)).to be false
      end

      it "checks that the participant has a induction record" do
        participant_profile.induction_records.destroy_all
        expect(form.valid?(:select_school)).to be false
        expect(form.errors[:latest_induction_record]).to be_present
      end
    end

    context "when :start_date step" do
      it { is_expected.to validate_presence_of(:start_date).on(:start_date) }

      it "checks that the start_date is not prior to the latest induction record start_date" do
        form.start_date = 2.days.ago
        expect(form.valid?(:start_date)).to be false
        expect(form.errors[:start_date]).to be_present
      end

      it "checks that the participant has a induction record" do
        participant_profile.induction_records.destroy_all
        expect(form.valid?(:start_date)).to be false
        expect(form.errors[:latest_induction_record]).to be_present
      end
    end

    context "when email step" do
      context "when a valid email is entered" do
        it "returns true" do
          form.email = "jackmiller@example.com"
          expect(form.valid?(:email)).to be true
          expect(form.errors[:email]).to be_empty
        end
      end

      context "when a invalid email is entered" do
        it "returns false" do
          form.email = "jackmiller@"
          expect(form.valid?(:email)).to be false
          expect(form.errors[:email]).to be_present
        end
      end

      context "when a no email is entered" do
        it "returns false" do
          form.email = nil
          expect(form.valid?(:email)).to be false
          expect(form.errors[:email]).to be_present
        end
      end

      context "when an already in use email is entered" do
        let(:user) { create(:user, email: "terry@example.com") }
        it "returns false" do
          form.email = user.email
          expect(form.valid?(:email)).to be false
          expect(form.errors[:email]).to be_present
        end
      end

      context "when participant is missing their induction record" do
        before do
          participant_profile.induction_records.destroy_all
        end

        it "returns false" do
          form.email = "jackmiller@example.com"
          expect(form.valid?(:email)).to be false
          expect(form.errors[:latest_induction_record]).to be_present
        end
      end
    end
  end
end
