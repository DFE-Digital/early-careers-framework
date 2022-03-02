# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Given an ECT from another school has been transferred before a started declaration has occurred",
              type: :feature do
  include Steps::TransferParticipantSteps

  let(:cohort) { create :cohort, :current }
  let(:privacy_policy) { create :privacy_policy }
  let(:lead_providers) { [] }
  let(:tokens) { {} }
  let(:sits) { [] }
  let(:participants) { [] }

  let(:original_lead_provider) { lead_providers[0] }
  let(:original_sit) { sits[0] }

  let(:new_lead_provider) { lead_providers[1] }
  let(:new_sit) { sits[1] }

  let(:another_lead_provider) { lead_providers[lead_providers.length - 1] }

  context "When they have changed from doing a FIP onto a CIP" do
    before do
      given_lead_provider_contracted_to_deliver_ecf
      and_another_lead_provider_contracted_to_deliver_ecf
      and_sit_reported_programme :fip
      and_another_sit_reported_programme :cip
      and_sit_reported_ect_participant original_sit
      and_lead_provider_reported_partnership original_lead_provider, original_sit

      when_sit_takes_on_the_participant new_sit, participant
    end

    context "Then the ECT" do
      subject(:participant) { participants[0] }

      scenario "can be seen by the new SIT" do
        expect(participant).to be_seen_by_sit new_sit
      end

      scenario "cannot be seen by the previous SIT" do
        expect(participant).not_to be_seen_by_sit original_sit
      end

      scenario "cannot be seen by the original Lead Provider" do
        expect(participant).not_to have_details_available_to_lead_provider original_lead_provider
      end

      scenario "cannot be seen by another Lead Provider" do
        expect(participant).not_to have_details_available_to_lead_provider another_lead_provider
      end

      scenario "is reported Support for ECTs as an ECT on the CIP programme" do
        expect(participant).to be_reported_to_support_as_an_ect_on :cip
      end
    end
  end

  context "When they have changed from doing a CIP onto a CIP" do
    before do
      given_lead_provider_contracted_to_deliver_ecf
      and_sit_reported_programme :cip
      and_another_sit_reported_programme :cip
      and_sit_reported_ect_participant original_sit

      when_sit_takes_on_the_participant new_sit, participant
    end

    context "Then the ECT" do
      subject(:participant) { participants[0] }
      let(:any_lead_provider) { lead_providers[lead_providers.length - 1] }

      scenario "can be seen by the new SIT" do
        expect(participant).to be_seen_by_sit new_sit
      end

      scenario "cannot be seen by the previous SIT" do
        expect(participant).not_to be_seen_by_sit original_sit
      end

      scenario "cannot be seen by any Lead Provider" do
        expect(participant).to_not have_details_available_to_lead_provider any_lead_provider
      end

      scenario "is reported Support for ECTs as an ECT on the CIP programme" do
        expect(participant).to be_reported_to_support_as_an_ect_on :cip
      end
    end
  end

  context "When they have changed from doing a FIP onto a FIP with the same provider" do
    before do
      given_lead_provider_contracted_to_deliver_ecf
      and_another_lead_provider_contracted_to_deliver_ecf
      and_sit_reported_programme :fip
      and_another_sit_reported_programme :fip
      and_sit_reported_ect_participant original_sit
      and_lead_provider_reported_partnership original_lead_provider, original_sit
      and_another_lead_provider_reported_partnership original_lead_provider, new_sit

      when_sit_takes_on_the_participant new_sit, participant
      and_lead_provider_declared_training_started original_lead_provider, participant
    end

    context "Then the ECT" do
      subject(:participant) { participants[0] }

      scenario "can be seen by the new SIT" do
        expect(participant).to be_seen_by_sit new_sit
      end

      scenario "cannot be seen by the previous SIT" do
        expect(participant).not_to be_seen_by_sit original_sit
      end

      scenario "can be seen by the original Lead Provider" do
        expect(participant).to have_details_available_to_lead_provider original_lead_provider
      end

      scenario "cannot be seen by another Lead Provider" do
        expect(participant).to_not have_details_available_to_lead_provider another_lead_provider
      end

      scenario "is reported Support for ECTs as an ECT on the FIP programme" do
        expect(participant).to be_reported_to_support_as_an_ect_on :fip
      end
    end

    context "Then the ECTs Started Declaration" do
      subject(:participant) { participants[0] }

      scenario "can be seen by the original Lead Provider" do
        expect(participant).to have_declarations_available_to_lead_provider original_lead_provider
      end

      scenario "cannot be seen by another Lead Provider" do
        expect(participant).to_not have_declarations_available_to_lead_provider another_lead_provider
      end
    end

    # what can admins see ??
    # would they appear in the payment break down at this point ??
    # what can support users see ??
    # what would analytics have triggered ??
    #
    # check that expected onward actions are available to new school - what are they ??
  end

  context "When they have changed from doing a FIP onto a FIP with a different provider" do
    before do
      given_lead_provider_contracted_to_deliver_ecf
      and_another_lead_provider_contracted_to_deliver_ecf
      and_another_lead_provider_contracted_to_deliver_ecf
      and_sit_reported_programme :fip
      and_another_sit_reported_programme :fip
      and_sit_reported_ect_participant original_sit
      and_lead_provider_reported_partnership original_lead_provider, original_sit
      and_another_lead_provider_reported_partnership new_lead_provider, new_sit

      when_sit_takes_on_the_participant new_sit, participant
      and_lead_provider_declared_training_started original_lead_provider, participant
    end

    context "Then the ECT" do
      subject(:participant) { participants[0] }

      scenario "can be seen by the new SIT" do
        expect(participant).to be_seen_by_sit new_sit
      end

      scenario "cannot be seen by the previous SIT" do
        expect(participant).not_to be_seen_by_sit original_sit
      end

      scenario "can be seen by the new Lead Provider" do
        expect(participant).to have_details_available_to_lead_provider new_lead_provider
      end

      scenario "cannot be seen by the original Lead Provider" do
        expect(participant).to_not have_details_available_to_lead_provider original_lead_provider
      end

      scenario "cannot be seen by another Lead Provider" do
        expect(participant).to_not have_details_available_to_lead_provider another_lead_provider
      end

      scenario "is reported Support for ECTs as an ECT on the FIP programme" do
        expect(participant).to be_reported_to_support_as_an_ect_on :fip
      end
    end

    context "Then the ECTs Started Declaration" do
      subject(:participant) { participants[0] }

      scenario "can be seen by the new Lead Provider",
               skip: "Not implemented yet" do
        expect(participant).to have_declarations_available_to_lead_provider new_lead_provider
      end

      scenario "cannot be seen by the original Lead Provider" do
        expect(participant).to_not have_declarations_available_to_lead_provider original_lead_provider
      end

      scenario "cannot be seen by another Lead Provider" do
        expect(participant).to_not have_declarations_available_to_lead_provider another_lead_provider
      end
    end
  end

  context "When they have changed from doing a CIP onto a FIP" do
    before do
      given_lead_provider_contracted_to_deliver_ecf
      and_another_lead_provider_contracted_to_deliver_ecf
      and_sit_reported_programme :cip
      and_another_sit_reported_programme :fip
      and_sit_reported_ect_participant original_sit
      and_lead_provider_reported_partnership original_lead_provider, new_sit

      when_sit_takes_on_the_participant new_sit, participant
      and_lead_provider_declared_training_started original_lead_provider, participant
    end

    context "Then the ECT" do
      subject(:participant) { participants[0] }

      scenario "can be seen by the new SIT" do
        expect(participant).to be_seen_by_sit new_sit
      end

      scenario "cannot be seen by the previous SIT" do
        expect(participant).not_to be_seen_by_sit original_sit
      end

      scenario "can be seen by the new Lead Provider" do
        expect(participant).to have_details_available_to_lead_provider original_lead_provider
      end

      scenario "cannot be seen by another Lead Provider" do
        expect(participant).not_to have_details_available_to_lead_provider new_lead_provider
      end

      scenario "is reported Support for ECTs as an ECT on the FIP programme" do
        expect(participant).to be_reported_to_support_as_an_ect_on :fip
      end
    end

    context "Then the ECTs Started Declaration" do
      subject(:participant) { participants[0] }

      scenario "can be seen by the new Lead Provider" do
        expect(participant).to have_declarations_available_to_lead_provider original_lead_provider
      end

      scenario "cannot be seen by another Lead Provider" do
        expect(participant).not_to have_declarations_available_to_lead_provider new_lead_provider
      end
    end
  end
end
