# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::JoinSchoolProgrammeStep, type: :model do
  let(:wizard) { double }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:join_school_programme).in_array(%w[default_for_participant_cohort default_for_current_cohort other_providers]) }
  end

  describe ".permitted_params" do
    it "returns permitted parameters" do
      expect(described_class.permitted_params).to eql %i[join_school_programme]
    end
  end

  describe "#next_step" do
    context "when the participant will join the school's programme" do
      it "returns :check_answers" do
        allow(wizard).to receive(:join_school_programme?).and_return(:default_for_current_cohort)
        expect(step.next_step).to eql :check_answers
      end
    end

    context "when the participant will not join the school's programme" do
      it "returns :cannot_add_manual_transfer" do
        allow(wizard).to receive(:join_school_programme?).and_return(nil)
        expect(step.next_step).to eql :cannot_add_manual_transfer
      end
    end
  end

  describe "#choices" do
    let(:participant_cohort_lead_provider) {}
    let(:participant_cohort_delivery_partner) {}
    let(:current_cohort_lead_provider) {}
    let(:current_cohort_delivery_partner) {}

    before do
      allow(wizard).to receive(:lead_provider).and_return(participant_cohort_lead_provider)
      allow(wizard).to receive(:delivery_partner).and_return(participant_cohort_delivery_partner)
      allow(wizard).to receive(:current_cohort_lead_provider).and_return(current_cohort_lead_provider)
      allow(wizard).to receive(:current_cohort_delivery_partner).and_return(current_cohort_delivery_partner)
    end

    context "when the participant school cohort has a default LP/DP programme" do
      let(:participant_cohort_lead_provider) { instance_double(LeadProvider, name: "LP1") }
      let(:participant_cohort_delivery_partner) { instance_double(DeliveryPartner, name: "DP1") }

      it "include the combo in the list of options" do
        expect(step.choices).to include(OpenStruct.new(id: :default_for_participant_cohort,
                                                       name: "LP1 with DP1"))
      end

      it "include other providers in the list of options" do
        expect(step.choices).to include(OpenStruct.new(id: :other_providers,
                                                       name: "Another training providers or programme"))
      end

      context "when the latest school cohort has the same default LP/DP programme as the participant school cohort" do
        let(:current_cohort_lead_provider) { instance_double(LeadProvider, name: "LP1") }
        let(:current_cohort_delivery_partner) { instance_double(DeliveryPartner, name: "DP1") }

        it "do not include the combo in the list of options" do
          expect(step.choices).not_to include(OpenStruct.new(id: :default_for_current_cohort,
                                                             name: "LP1 with DP1"))
        end
      end

      context "when the latest school cohort has a default current LP/DP programme other than the participant school cohort" do
        let(:current_cohort_lead_provider) { instance_double(LeadProvider, name: "LP2") }
        let(:current_cohort_delivery_partner) { instance_double(DeliveryPartner, name: "DP2") }

        it "include the combo in the list of options" do
          expect(step.choices).to include(OpenStruct.new(id: :default_for_current_cohort,
                                                         name: "LP2 with DP2"))
        end
      end
    end

    context "when the participant school cohort has no default LP/DP programme" do
      context "when the latest school cohort has a default current LP/DP programme" do
        let(:current_cohort_lead_provider) { instance_double(LeadProvider, name: "LP2") }
        let(:current_cohort_delivery_partner) { instance_double(DeliveryPartner, name: "DP2") }

        it "include the combo in the list of options" do
          expect(step.choices).to include(OpenStruct.new(id: :default_for_current_cohort,
                                                         name: "LP2 with DP2"))
        end

        it "include other providers in the list of options" do
          expect(step.choices).to include(OpenStruct.new(id: :other_providers,
                                                         name: "Another training providers or programme"))
        end
      end
    end
  end
end
