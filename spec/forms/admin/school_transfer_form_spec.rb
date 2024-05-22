# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::SchoolTransferForm, type: :model do
  subject(:form) { described_class.new(participant_profile_id: participant_profile.id, new_school_urn: school_in.urn) }
  let(:participant_profile) { create :ect_participant_profile }
  let(:cohort) { participant_profile.schedule.cohort }
  let(:induction_programme_out) do
    NewSeeds::Scenarios::SchoolCohorts::Fip.new(cohort:)
                                           .build
                                           .with_programme
                                           .school_cohort
                                           .default_induction_programme
  end
  let(:lead_provider_out) { induction_programme_out.lead_provider }
  let(:delivery_partner_out) { induction_programme_out.delivery_partner }
  let!(:induction_record) do
    Induction::Enrol.call(participant_profile:,
                          induction_programme: induction_programme_out,
                          start_date: 1.day.ago)
  end

  let(:school_in) { create(:school) }

  describe "#cannot_transfer_to_new_school?" do
    context "when new school doesn't have any programmes in participant's cohort" do
      it "returns true" do
        expect(form.cannot_transfer_to_new_school?).to be true
      end
    end
  end

  describe "#perform_transfer!" do
    let(:partnership_in) {}
    let(:school_cohort_in) do
      NewSeeds::Scenarios::SchoolCohorts::Fip.new(cohort:, school: school_in)
                                             .build
                                             .with_programme(partnership: partnership_in)
                                             .school_cohort
    end
    let(:induction_programme_in) { school_cohort_in.induction_programmes.first }
    let(:transfer_choice) { induction_programme_in.id }
    let(:lead_provider_in) { induction_programme_in.lead_provider }
    let(:create_providers_users) { true }

    before do
      NewSeeds::Scenarios::Users::LeadProviderUser.new(lead_provider: lead_provider_out).build if create_providers_users
      NewSeeds::Scenarios::Users::LeadProviderUser.new(lead_provider: lead_provider_in).build  if create_providers_users
      # school_cohort.update!(default_induction_programme: induction_programme_in)
      form.start_date = 10.days.from_now
      form.email = "ted.jones@example.com"
      form.transfer_choice = transfer_choice
    end

    it "adds a new induction record" do
      expect { form.perform_transfer! }.to change { participant_profile.induction_records.count }.by(1)
    end

    it "enrols the participant in the selected programme" do
      form.perform_transfer!
      expect(participant_profile.induction_records.latest.induction_programme).to eq induction_programme_in
    end

    it "notifies the providers and the participant" do
      expect {
        form.perform_transfer!
      }.to have_enqueued_mail(ParticipantTransferMailer, :provider_transfer_in_notification)
             .with(params: hash_including(lead_provider_profile: lead_provider_in.lead_provider_profiles.first),
                   args: [])
       .and have_enqueued_mail(ParticipantTransferMailer, :provider_transfer_out_notification)
              .with(params: hash_including(lead_provider_profile: lead_provider_out.lead_provider_profiles.first),
                    args: [])
    end

    context "when continuing current programme" do
      let(:transfer_choice) { "continue" }

      it "enrols the participant in the selected programme" do
        form.perform_transfer!
        expect(participant_profile.induction_records.latest.induction_programme)
          .to eq school_cohort_in.induction_programmes.order(:created_at).last
      end

      it "notifies the provider and the participant" do
        expect {
          form.perform_transfer!
        }.to have_enqueued_mail(ParticipantTransferMailer, :provider_existing_school_transfer_notification)
               .with(params: hash_including(lead_provider_profile: lead_provider_out.lead_provider_profiles.first),
                     args: [])
      end

      context "when a matching programme already exists" do
        let(:partnership_in) do
          FactoryBot.create(:seed_partnership,
                            cohort:,
                            school: school_in,
                            delivery_partner: delivery_partner_out,
                            lead_provider: lead_provider_out)
        end

        it "does not create a new programme" do
          expect { form.perform_transfer! }.not_to change { school_cohort_in.induction_programmes.count }
        end

        it "enrols the participant in the matching programme" do
          form.perform_transfer!
          expect(participant_profile.induction_records.latest.induction_programme).to eq induction_programme_in
        end
      end

      context "when there is no school cohort at the school" do
        let(:create_providers_users) { false }

        it "creates a new school cohort" do
          expect { form.perform_transfer! }.to change { school_in.school_cohorts.count }.by(1)
        end

        it "sets the induction programme choice on the school cohort" do
          form.perform_transfer!
          expect(school_in.school_cohorts.first).to be_full_induction_programme
        end

        it "sets the default induction programme on the school cohort to be the new programme" do
          form.perform_transfer!
          expect(school_in.school_cohorts.first.default_induction_programme).to eq school_in.school_cohorts.first.induction_programmes.first
        end
      end
    end
  end

  describe "#skip_transfer_options?" do
    context "when the destination school has more than one programme in the cohort" do
      let(:school_cohort) { create(:school_cohort, :fip, :with_induction_programme, school: school_in, cohort:) }
      let!(:induction_programme_in) { create(:induction_programme, :fip, school_cohort:) }

      it "returns false" do
        expect(form.skip_transfer_options?).to be false
      end
    end

    context "when the destination school has a different programme in the cohort" do
      let!(:school_cohort) { create(:school_cohort, :cip, :with_induction_programme, school: school_in, cohort:) }

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
      let!(:school_cohort) { create(:school_cohort, :fip, :with_induction_programme, school: school_in, cohort:) }

      context "when the programme matches the participants induction programme" do
        let(:partnership) do
          FactoryBot.create(:seed_partnership,
                            cohort:,
                            school: school_in,
                            delivery_partner: delivery_partner_out,
                            lead_provider: lead_provider_out)
        end

        let!(:school_cohort) do
          NewSeeds::Scenarios::SchoolCohorts::Fip.new(cohort:, school: school_in)
                                                 .build
                                                 .with_programme(partnership:)
                                                 .school_cohort
        end

        it "returns true" do
          expect(form.skip_transfer_options?).to be true
        end
      end

      context "when the participant does not have an induction record" do
        before do
          induction_record.destroy
        end

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
        form.new_school_urn = participant_profile.latest_induction_record.school.urn
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

      it "handles argument errors on start_date" do
        form.start_date = { 3 => 22, 2 => 111, 1 => 2222 }
        expect(form.valid?(:start_date)).to be false
        expect(form.errors.added?(:start_date, :invalid)).to be true
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
