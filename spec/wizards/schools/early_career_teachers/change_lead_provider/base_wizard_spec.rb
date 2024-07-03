# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schools::EarlyCareerTeachers::ChangeLeadProvider::BaseWizard do
  let(:current_step) { :intro }
  subject { described_class.new(current_step:) }

  describe "#steps" do
    it "returns the correct steps" do
      expect(subject.steps).to eq(
        [{
          intro: Schools::EarlyCareerTeachers::ChangeLeadProvider::IntroStep,
          start: Schools::EarlyCareerTeachers::ChangeLeadProvider::StartStep,
          contact_providers: Schools::EarlyCareerTeachers::ChangeLeadProvider::ContactProvidersStep,
          email: Schools::EarlyCareerTeachers::ChangeLeadProvider::EmailStep,
          lead_provider: Schools::EarlyCareerTeachers::ChangeLeadProvider::LeadProviderStep,
          check_your_answers: Schools::EarlyCareerTeachers::ChangeLeadProvider::CheckYourAnswersStep,
          success: Schools::EarlyCareerTeachers::ChangeLeadProvider::SuccessStep,
        }],
      )
    end
  end

  describe "#default_path_arguments" do
    let(:school_id) { SecureRandom.uuid }
    let(:participant_id) { SecureRandom.uuid }
    let(:start_year) { 2022 }
    subject { described_class.new(current_step:, school_id:, participant_id:, start_year:) }

    it "returns the correct arguments" do
      expect(subject.default_path_arguments).to eq(
        { school_id:, participant_id:, start_year: },
      )
    end
  end

  describe "#save!" do
    let(:current_step) { :start }
    let(:store) { instance_double(FormData::ChangeLeadProviderStore) }
    let(:step_params) { ActionController::Parameters.new({ start: { answer: "yes" } }) }

    subject do
      described_class.new(
        current_step:,
        store:,
        step_params:,
      )
    end

    before do
      allow(store).to receive(:complete?).and_return(false)
      allow(store).to receive(:set)
    end

    it "saves the step params to the store" do
      subject.save!

      expect(store).to have_received(:set).with("answer", "yes")
    end

    context "when the wizard is complete" do
      let(:current_step) { :check_your_answers }
      let(:current_user) { instance_double(User) }
      let(:participant_id) { SecureRandom.uuid }
      let(:participant) do
        instance_double(
          ParticipantProfile::ECT,
          user: instance_double(User, email: "participant@example.com"),
          id: participant_id,
        )
      end
      let(:email) { "different@example.com" }
      let(:school_id) { SecureRandom.uuid }
      let(:school) { instance_double(School, name: "Big School", id: school_id) }
      let(:start_year) { 2022 }
      let(:current_lead_provider_id) { SecureRandom.uuid }
      let(:current_lead_provider) { instance_double(LeadProvider, name: "Current Lead Provider", id: current_lead_provider_id) }
      let(:new_lead_provider_id) { SecureRandom.uuid }
      let(:new_lead_provider) { instance_double(LeadProvider, name: "New Lead Provider", id: new_lead_provider_id) }
      let(:step_params) do
        ActionController::Parameters.new({ check_your_answers: { complete: "true" } })
      end

      subject do
        described_class.new(
          current_step:,
          store:,
          step_params:,
          current_user:,
          participant_id:,
          school_id:,
          start_year:,
        )
      end

      before do
        allow(store).to receive(:complete?).and_return(true)
        allow(store).to receive(:lead_provider_id).and_return(new_lead_provider_id)
        allow(store).to receive(:email).and_return(email)
        allow(store).to receive(:destroy)
        allow(ParticipantProfile::ECT).to receive(:find).with(participant_id).and_return(participant)
        allow(LeadProvider).to receive(:find).with(current_lead_provider_id).and_return(current_lead_provider)
        allow(LeadProvider).to receive(:find).with(new_lead_provider_id).and_return(new_lead_provider)
        allow(School).to receive(:find).with(school_id).and_return(school)
        allow(school).to receive(:lead_provider).with(start_year).and_return(current_lead_provider)
        allow(CreateChangeLeadProviderSupportQuery).to receive(:call)
      end

      it "creates a support query" do
        subject.save!

        expect(CreateChangeLeadProviderSupportQuery).to have_received(:call).with(
          current_user:,
          participant:,
          email:,
          school:,
          start_year:,
          current_lead_provider:,
          new_lead_provider:,
        )
      end

      it "destroys the store" do
        subject.save!

        expect(store).to have_received(:destroy)
      end
    end
  end
end
