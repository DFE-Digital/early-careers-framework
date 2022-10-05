# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolTransferForm, type: :model do
  subject(:form) { described_class.new(participant_profile_id: participant_profile.id) }
  let(:participant_profile) { create :ect_participant_profile }
  let(:induction_programme) { create(:induction_programme, :cip) }
  let!(:induction_record) { Induction::Enrol.call(participant_profile:, induction_programme:, start_date: 1.day.ago) }

  describe "#perform_transfer!" do
    let(:school_cohort) { create(:school_cohort, :fip, :with_induction_programme, cohort: participant_profile.schedule.cohort) }
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
    end

    context "when :start_date step" do
      it { is_expected.to validate_presence_of(:start_date).on(:start_date) }

      it "checks that the start_date is not prior to the latest induction record start_date" do
        form.start_date = 2.days.ago
        expect(form.valid?(:start_date)).to be false
        expect(form.errors[:start_date]).to be_present
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
    end
  end
end
