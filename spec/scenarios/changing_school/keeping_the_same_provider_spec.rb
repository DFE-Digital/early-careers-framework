# frozen_string_literal: true

require "rails_helper"

RSpec.describe "An ECT is moved to a new school" do
  context "Given three lead providers are contracted to deliver FIP" do
    before(:each) do
      three_lead_providers_are_contracted_to_deliver_fip
    end

    context "and two schools have chosen the FIP programme for the 2021 cohort" do
      before(:each) do
        two_schools_on_the_fip_programme_for_the_2021_cohort
      end

      context "and the first school has one participant" do
        before(:each) do
          the_first_school_has_one_participant
        end

        context "and two schools are partnered with the same provider" do
          before(:each) do
            two_schools_are_partnered_with_the_same_provider
          end

          context "when the second school takes on the participant" do
            before(:each) do
              the_second_school_takes_on_the_participant
            end

            # then
            it "cannot be seen by the first school" do
              assert_equal 0, @school_1.ecf_participant_profiles.length
            end

            # then
            it "can be seen by the second school" do
              assert_equal 1, @school_2.ecf_participant_profiles.length
              assert_equal @participant, @school_2.ecf_participant_profiles.first
            end

            # then
            it "can still be seen by the partnered lead provider" do
              assert_equal 1, @lead_provider_1.ecf_participant_profiles.length
              assert_equal @participant, @lead_provider_1.ecf_participant_profiles.first
            end

            # then
            it "cannot be seen by the other lead providers" do
              assert_equal 0, @lead_provider_3.ecf_participant_profiles.length
              assert_equal 0, @lead_provider_3.ecf_participant_profiles.length
            end
          end
        end

        context "and two schools are partnered with different providers" do
          before(:each) do
            two_schools_are_partnered_with_different_providers
          end

          context "when the second school takes on the participant" do
            before(:each) do
              the_second_school_takes_on_the_participant
            end

            # then
            it "cannot be seen by the first school" do
              assert_equal 0, @school_1.ecf_participant_profiles.length
            end

            # then
            it "can be seen by the second school" do
              assert_equal 1, @school_2.ecf_participant_profiles.length
              assert_equal @participant, @school_2.ecf_participant_profiles.first
            end

            # then
            it "can be seen by the second lead provider" do
              assert_equal 1, @lead_provider_2.ecf_participant_profiles.length
              assert_equal @participant, @lead_provider_2.ecf_participant_profiles.first
            end

            # then
            it "cannot be seen by the other lead providers" do
              assert_equal 0, @lead_provider_1.ecf_participant_profiles.length
              assert_equal 0, @lead_provider_3.ecf_participant_profiles.length
            end
          end
        end
      end
    end
  end

private

  def three_lead_providers_are_contracted_to_deliver_fip
    @lead_provider_1 = create :lead_provider
    @lead_provider_2 = create :lead_provider
    @lead_provider_3 = create :lead_provider

    @delivery_partner_1 = create :delivery_partner
    @delivery_partner_2 = create :delivery_partner
    @delivery_partner_3 = create :delivery_partner
  end

  def two_schools_on_the_fip_programme_for_the_2021_cohort
    @cohort_2021 = create :cohort, start_year: 2021

    @school_1 = create :school
    @school_2 = create :school

    @school_cohort_1 = create :school_cohort, :fip,
                              cohort: @cohort_2021,
                              school: @school_1
    @school_cohort_2 = create :school_cohort, :fip,
                              cohort: @cohort_2021,
                              school: @school_2
  end

  def two_schools_are_partnered_with_the_same_provider
    create :partnership,
           school: @school_1,
           lead_provider: @lead_provider_1,
           delivery_partner: @delivery_partner_1,
           cohort: @cohort_2021,
           challenge_deadline: 2.weeks.ago

    create :partnership,
           school: @school_2,
           lead_provider: @lead_provider_1,
           delivery_partner: @delivery_partner_1,
           cohort: @cohort_2021,
           challenge_deadline: 2.weeks.ago
  end

  def two_schools_are_partnered_with_different_providers
    create :partnership,
           school: @school_1,
           lead_provider: @lead_provider_1,
           delivery_partner: @delivery_partner_1,
           cohort: @cohort_2021,
           challenge_deadline: 2.weeks.ago

    create :partnership,
           school: @school_2,
           lead_provider: @lead_provider_2,
           delivery_partner: @delivery_partner_2,
           cohort: @cohort_2021,
           challenge_deadline: 2.weeks.ago
  end

  def the_first_school_has_one_participant
    @participant = create :ect_participant_profile,
                          school_cohort: @school_cohort_1
  end

  def the_second_school_takes_on_the_participant
    @participant.update!(school_cohort: @school_cohort_2)
    @participant.teacher_profile.update!(school: @school_cohort_2.school)
  end
end
