# frozen_string_literal: true

require "rails_helper"

RSpec.feature "after Transferring the only ECT from another school onto a FIP", type: :feature do
  include Steps::TransferParticipantSteps

  before do
    # we have to run this in the current cohort because logic in the service enforces SITs declaring current cohort
    @cohort = create :cohort, :current
    @privacy_policy = create :privacy_policy

    @lead_providers = []
    @tokens = {}
    @sits = []
    @participants = []
  end

  context "from a FIP with same provider, before a started declaration has occurred" do
    before do
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
      then_participant_details_can_be_seen_by_lead_provider @lead_providers.first,
                                                            @participants.first
    end

    scenario "the ECT cannot be seen by another Lead Provider" do
      then_participant_details_cannot_be_seen_by_lead_provider @lead_providers[1],
                                                               @participants.first
    end

    # what can admins see ??
    # would they appear in the payment break down at this point ??
    # what can support users see ??
    # what would analytics have triggered ??
    #
    # check that expected onward actions are available to new school - what are they ??

    scenario "the ECT is recognised as a FIP ECT for Support ECTs" do
      then_participant_is_fip_ect_for_support_ects @participants.first
    end
  end

  context "from a FIP with a different provider, before a started declaration has occurred" do
    before do
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
      then_participant_details_can_be_seen_by_lead_provider @lead_providers[1],
                                                            @participants.first
    end

    scenario "the ECT cannot be seen by the original Lead Provider" do
      then_participant_details_cannot_be_seen_by_lead_provider @lead_providers.first,
                                                               @participants.first
    end

    scenario "the ECT cannot be seen by another Lead Provider" do
      then_participant_details_cannot_be_seen_by_lead_provider @lead_providers[2],
                                                               @participants.first
    end

    scenario "the ECT is recognised as a FIP ECT for Support ECTs" do
      then_participant_is_fip_ect_for_support_ects @participants.first
    end
  end

  context "from a CIP, before a started declaration has occurred" do
    before do
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
      then_participant_details_can_be_seen_by_lead_provider @lead_providers.first,
                                                            @participants.first
    end

    scenario "the ECT cannot be seen by another Lead Provider" do
      then_participant_details_cannot_be_seen_by_lead_provider @lead_providers[1],
                                                               @participants.first
    end

    scenario "the ECT is recognised as a FIP ECT for Support ECTs" do
      then_participant_is_fip_ect_for_support_ects @participants.first
    end
  end
end
