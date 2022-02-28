# frozen_string_literal: true

require "rails_helper"
require_relative "./transfer_participant_steps"

RSpec.feature "After Transferring the only ECT from another school", type: :feature do
  include TransferParticipantSteps

  context "from FIP to FIP with same provider" do
    before do
      # we have to run this in the current cohort because logic in the service enforces SITs declaring current cohort
      @cohort = create :cohort, :current
      @privacy_policy = create :privacy_policy

      @lead_providers = []
      @lead_provider_tokens = []
      @sits = []
      @participants = []

      given_lead_provider_contracted_to_deliver_ecf
      and_another_lead_provider_contracted_to_deliver_ecf
      and_sit_reported_programme :fip
      and_another_sit_reported_programme :fip
      and_sit_reported_ect_participant @sits.first
      and_lead_provider_reported_partnership @lead_providers.first, @sits.first.schools.first
      and_another_lead_provider_reported_partnership @lead_providers.first, @sits[1].schools.first

      when_sit_takes_on_the_participant @sits[1], @participants.first
    end

    scenario "the ECT can be seen by the new SIT" do
      then_participant_can_be_seen_by_fip_sit @sits[1],
                                              @participants.first
    end

    scenario "the ECT cannot be seen by the previous SIT" do
      then_participant_cannot_be_seen_by_fip_sit @sits.first,
                                                 @participants.first
    end

    scenario "the ECT can be seen by the original Lead Provider" do
      then_participant_can_be_seen_by_lead_provider @lead_providers.first,
                                                    @lead_provider_tokens.first,
                                                    @participants.first
    end

    scenario "the ECT cannot be seen by another Lead Provider" do
      then_participant_cannot_be_seen_by_lead_provider @lead_providers[1],
                                                       @lead_provider_tokens[1],
                                                       @participants.first
    end
  end

  context "from FIP to FIP with different provider" do
    before do
      # we have to run this in the current cohort because logic in the service enforces SITs declaring current cohort
      @cohort = create :cohort, :current
      @privacy_policy = create :privacy_policy

      @lead_providers = []
      @lead_provider_tokens = []
      @sits = []
      @participants = []

      given_lead_provider_contracted_to_deliver_ecf
      and_another_lead_provider_contracted_to_deliver_ecf
      and_another_lead_provider_contracted_to_deliver_ecf
      and_sit_reported_programme :fip
      and_another_sit_reported_programme :fip
      and_sit_reported_ect_participant @sits.first
      and_lead_provider_reported_partnership @lead_providers.first, @sits.first.schools.first
      and_another_lead_provider_reported_partnership @lead_providers[1], @sits[1].schools.first

      when_sit_takes_on_the_participant @sits[1], @participants.first
    end

    scenario "the ECT can be seen by the new SIT" do
      then_participant_can_be_seen_by_fip_sit @sits[1],
                                              @participants.first
    end

    scenario "the ECT cannot be seen by the previous SIT" do
      then_participant_cannot_be_seen_by_fip_sit @sits.first,
                                                 @participants.first
    end

    scenario "the ECT can be seen by the new Lead Provider" do
      then_participant_can_be_seen_by_lead_provider @lead_providers[1],
                                                    @lead_provider_tokens[1],
                                                    @participants.first
    end

    scenario "the ECT cannot be seen by the original Lead Provider" do
      then_participant_cannot_be_seen_by_lead_provider @lead_providers.first,
                                                       @lead_provider_tokens.first,
                                                       @participants.first
    end

    scenario "the ECT cannot be seen by another Lead Provider" do
      then_participant_cannot_be_seen_by_lead_provider @lead_providers[2],
                                                       @lead_provider_tokens[2],
                                                       @participants.first
    end
  end

  context "from CIP to FIP" do
    before do
      # we have to run this in the current cohort because logic in the service enforces SITs declaring current cohort
      @cohort = create :cohort, :current
      @privacy_policy = create :privacy_policy

      @lead_providers = []
      @lead_provider_tokens = []
      @sits = []
      @participants = []

      given_lead_provider_contracted_to_deliver_ecf
      and_another_lead_provider_contracted_to_deliver_ecf
      and_sit_reported_programme :cip
      and_another_sit_reported_programme :fip
      and_sit_reported_ect_participant @sits.first
      and_lead_provider_reported_partnership @lead_providers[0], @sits[1].schools.first

      when_sit_takes_on_the_participant @sits[1], @participants.first
    end

    scenario "the ECT can be seen by the new SIT" do
      then_participant_can_be_seen_by_fip_sit @sits[1],
                                              @participants.first
    end

    scenario "the ECT cannot be seen by the previous SIT" do
      then_participant_cannot_be_seen_by_cip_sit @sits.first,
                                                 @participants.first
    end

    scenario "the ECT can be seen by the new Lead Provider" do
      then_participant_can_be_seen_by_lead_provider @lead_providers.first,
                                                    @lead_provider_tokens.first,
                                                    @participants.first
    end

    scenario "the ECT cannot be seen by another Lead Provider" do
      then_participant_cannot_be_seen_by_lead_provider @lead_providers[1],
                                                       @lead_provider_tokens[1],
                                                       @participants.first
    end
  end

  context "from FIP to CIP" do
    before do
      # we have to run this in the current cohort because logic in the service enforces SITs declaring current cohort
      @cohort = create :cohort, :current
      @privacy_policy = create :privacy_policy

      @lead_providers = []
      @lead_provider_tokens = []
      @sits = []
      @participants = []

      given_lead_provider_contracted_to_deliver_ecf
      and_another_lead_provider_contracted_to_deliver_ecf
      and_sit_reported_programme :fip
      and_another_sit_reported_programme :cip
      and_sit_reported_ect_participant @sits.first
      and_lead_provider_reported_partnership @lead_providers.first, @sits.first.schools.first

      when_sit_takes_on_the_participant @sits[1], @participants.first
    end

    scenario "the ECT can be seen by the new SIT" do
      then_participant_can_be_seen_by_cip_sit @sits[1],
                                              @participants.first
    end

    scenario "the ECT cannot be seen by the previous SIT" do
      then_participant_cannot_be_seen_by_fip_sit @sits.first,
                                                 @participants.first
    end

    scenario "the ECT cannot be seen by the original Lead Provider" do
      then_participant_cannot_be_seen_by_lead_provider @lead_providers.first,
                                                       @lead_provider_tokens.first,
                                                       @participants.first
    end

    scenario "the ECT cannot be seen by another Lead Provider" do
      then_participant_cannot_be_seen_by_lead_provider @lead_providers[1],
                                                       @lead_provider_tokens[1],
                                                       @participants.first
    end
  end
end
