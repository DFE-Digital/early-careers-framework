# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schools::ChangeRequestSupportQuery::BaseWizard do
  let(:change_request_type) { "change-lead-provider" }
  let(:current_step) { :intro }
  let(:participant_id) { SecureRandom.uuid }
  subject { described_class.new(change_request_type:, current_step:) }

  describe "#steps" do
    it "returns the correct steps" do
      expect(subject.steps).to eq(
        [{
          start: Schools::ChangeRequestSupportQuery::StartStep,
          contact_providers: Schools::ChangeRequestSupportQuery::ContactProvidersStep,
          email: Schools::ChangeRequestSupportQuery::EmailStep,
          relation: Schools::ChangeRequestSupportQuery::RelationStep,
          check_your_answers: Schools::ChangeRequestSupportQuery::CheckYourAnswersStep,
          success: Schools::ChangeRequestSupportQuery::SuccessStep,
        }],
      )
    end
  end

  describe "#default_path_arguments" do
    let(:school_id) { SecureRandom.uuid }
    let(:participant_id) { SecureRandom.uuid }
    let(:start_year) { 2022 }
    subject { described_class.new(change_request_type:, current_step:, school_id:, participant_id:, start_year:) }

    it "returns the correct arguments" do
      expect(subject.default_path_arguments).to eq(
        { change_request_type:, school_id:, participant_id:, start_year: },
      )
    end
  end

  describe "#participant_change_request?" do
    let(:change_request_type) { "change-lead-provider" }
    let(:subject) { described_class.new(change_request_type:, current_step:, participant_id:) }

    it "returns true if participant_id is present" do
      expect(subject.participant_change_request?).to be true
    end

    context "when participant_id is blank" do
      let(:participant_id) { nil }

      it "returns false" do
        expect(subject.participant_change_request?).to be false
      end
    end
  end

  describe "#save!" do
    let(:current_step) { :start }
    let(:store) { instance_double(FormData::WizardStepStore) }
    let(:step_params) { ActionController::Parameters.new({ start: { answer: "yes" } }) }

    subject do
      described_class.new(
        current_step:,
        store:,
        step_params:,
      )
    end

    before do
      allow(store).to receive(:attrs_for)
      allow(store).to receive(:store_attrs)
    end

    it "saves the step params to the store" do
      subject.save!

      expect(store).to have_received(:store_attrs).with("start", "answer" => "yes")
    end

    context "when the wizard is complete" do
      let(:current_step) { :check_your_answers }
      let(:current_user) { instance_double(User) }
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
      let(:academic_year) { "2022 to 2023" }
      let(:start_year) { 2022 }
      let(:current_lead_provider_id) { SecureRandom.uuid }
      let(:current_lead_provider) { instance_double(LeadProvider, name: "Current Lead Provider", id: current_lead_provider_id) }
      let(:new_lead_provider_id) { SecureRandom.uuid }
      let(:new_lead_provider) { instance_double(LeadProvider, name: "New Lead Provider", id: new_lead_provider_id) }

      subject do
        described_class.new(
          change_request_type:,
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
        allow(store).to receive(:destroy)
        allow(store).to receive(:attrs_for).with(:email).and_return({ email: })
        allow(store).to receive(:attrs_for).with(:relation).and_return({ relation_id: new_lead_provider_id })
        allow(store).to receive(:attrs_for).with(:check_your_answers).and_return({ complete: "true" })
        allow(ParticipantProfile).to receive(:find).with(participant_id).and_return(participant)
        allow(LeadProvider).to receive(:find).with(current_lead_provider_id).and_return(current_lead_provider)
        allow(LeadProvider).to receive(:find).with(new_lead_provider_id).and_return(new_lead_provider)
        allow(School).to receive(:find).with(school_id).and_return(school)
        allow(school).to receive(:lead_provider).with(start_year).and_return(current_lead_provider)
        allow(CreateChangeRequestSupportQuery).to receive(:call)
      end

      it "creates a support query" do
        subject.save!

        expect(CreateChangeRequestSupportQuery).to have_received(:call).with(
          current_user:,
          participant:,
          school:,
          academic_year:,
          current_relation: current_lead_provider,
          new_relation: new_lead_provider,
        )
      end

      it "destroys the store" do
        subject.save!

        expect(store).to have_received(:destroy)
      end

      context "when the change request is for a delivery partner" do
        let(:change_request_type) { "change-delivery-partner" }
        let(:current_delivery_partner_id) { SecureRandom.uuid }
        let(:new_delivery_partner_id) { SecureRandom.uuid }
        let(:current_delivery_partner) { instance_double(DeliveryPartner, name: "Current Delivery Partner", id: current_delivery_partner_id) }
        let(:new_delivery_partner) { instance_double(DeliveryPartner, name: "New Delivery Partner", id: new_delivery_partner_id) }

        before do
          allow(store).to receive(:attrs_for).with(:relation).and_return({ relation_id: new_delivery_partner_id })
          allow(DeliveryPartner).to receive(:find).with(new_delivery_partner_id).and_return(new_delivery_partner)
          allow(school).to receive(:delivery_partner_for).with(start_year).and_return(current_delivery_partner)
        end

        it "creates a support query" do
          subject.save!

          expect(CreateChangeRequestSupportQuery).to have_received(:call).with(
            current_user:,
            participant:,
            school:,
            academic_year:,
            current_relation: current_delivery_partner,
            new_relation: new_delivery_partner,
          )
        end
      end
    end
  end
end
