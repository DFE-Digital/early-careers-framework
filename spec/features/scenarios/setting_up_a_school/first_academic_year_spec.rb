# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Set up first Academic Year for a school", type: :feature,
              with_feature_flags: { eligibility_notifications: "active" } do
  let!(:current_cohort) do
    Cohort.find_by(start_year: 2020) || create(:cohort, start_year: 2020) # NQT+1 cohort

    previous_cohort = Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021)
    current_cohort = Cohort.find_by(start_year: 2022) || create(:cohort, start_year: 2022)
    next_cohort = Cohort.find_by(start_year: 2023) || create(:cohort, start_year: 2023)

    allow(Cohort).to receive(:current).and_return(current_cohort)
    allow(Cohort).to receive(:next).and_return(next_cohort)
    allow(Cohort).to receive(:previous).and_return(previous_cohort)
    allow(Cohort).to receive(:active_registration_cohort).and_return(current_cohort)

    allow(Cohort).to receive(:within_automatic_assignment_period?).and_return(false)
    allow(Cohort).to receive(:within_next_registration_period?).and_return(false)

    current_cohort
  end

  let!(:privacy_policy) do
    privacy_policy = create(:privacy_policy)
    PrivacyPolicy::Publish.call
    privacy_policy
  end

  let!(:core_induction_programme) { create :core_induction_programme }
  let!(:appropriate_body) { create :appropriate_body_local_authority }

  let!(:lead_provider) { create :lead_provider, name: "Test Lead Provider" }
  let!(:lead_provider_user) do
    user = create(:user, full_name: lead_provider.name)
    create(:lead_provider_profile, user:, lead_provider:)
    user
  end
  let!(:delivery_partner) do
    delivery_partner = create(:delivery_partner, name: "#{lead_provider.name}'s Delivery Partner")
    create(:provider_relationship, lead_provider:, delivery_partner:, cohort: current_cohort)
    delivery_partner
  end

  context "Given a school with a SIT" do
    let(:school) { create :school }

    let!(:school_induction_tutor) do
      user = create(:user)
      create(:induction_coordinator_profile, schools: [school], user:)
      PrivacyPolicy.current.accept! user
      user
    end

    let(:school_cohort) { school.school_cohorts.for_year(current_cohort.start_year).first }
    let(:default_induction_programme) { school_cohort&.default_induction_programme }
    let(:partnership) { default_induction_programme&.partnership }

    context "When they have not set up any academic years yet" do
      it "Then it has a minimal school record" do
        # to be a minimal School
        expect(school).to be_a School
        expect(school.urn).to_not be_nil
        expect(school.name).to_not be_nil

        expect(school.induction_coordinator_profiles).to_not be_empty
        expect(school.partnerships).to be_empty
        expect(school.active_partnerships).to be_empty
        expect(school.school_cohorts).to be_empty
        expect(school.school_mentors).to be_empty
      end
    end

    context "When they have chosen a core induction programme for the next academic year" do
      let(:training_programme) { "core_induction_programme" }

      before do
        sign_in_as school_induction_tutor

        Pages::SchoolReportProgrammeWizard.loaded
                                          .complete(programme_type: "CIP")

        sign_out
      end

      it "Then it has a minimum school cohort record with a minimum core induction programme record" do
        # to be a School with a SchoolCohort
        expect(school.school_cohorts).to_not be_empty

        # to be a minimal SchoolCohort
        expect(school_cohort).to be_a SchoolCohort
        expect(school_cohort&.cohort).to eq current_cohort
        expect(school_cohort&.core_induction_programme).to be_nil
        expect(school_cohort&.appropriate_body).to be_nil
        expect(school_cohort&.ecf_participant_profiles).to be_empty
        expect(school_cohort&.mentor_profiles).to be_empty

        expect(school_cohort&.induction_programmes).to_not be_empty
      end

      it "And it has a minimum core induction programme record" do
        # to be a CIP SchoolCohort
        expect(school_cohort&.induction_programmes).to include default_induction_programme

        # to be a minimal InductionProgramme
        expect(default_induction_programme).to be_a InductionProgramme
        expect(default_induction_programme&.school_cohort).to eq school_cohort
        expect(default_induction_programme&.induction_records).to be_empty

        # to be a minimal CIP InductionProgramme
        expect(default_induction_programme&.training_programme).to eq training_programme
        expect(default_induction_programme&.core_induction_programme).to be_nil
        expect(default_induction_programme&.partnership).to be_nil
      end

      it "And they cannot add a participant", :skip do
      end

      context "And they have chosen the material for the next academic year" do
        before do
          sign_in_as school_induction_tutor

          Pages::SchoolDashboardPage.loaded
                                    .add_cip_materials(core_induction_programme.name)

          sign_out
        end

        it "Then it has a core induction programme with materials record as the default" do
          # to be a CIP SchoolCohort with materials chosen
          expect(school_cohort&.core_induction_programme).to eq core_induction_programme

          # to be a minimal Core InductionProgramme with materials
          expect(default_induction_programme&.training_programme).to eq training_programme
          expect(default_induction_programme&.core_induction_programme).to eq core_induction_programme
          expect(default_induction_programme&.partnership).to be_nil
        end

        it "And they can add a participant", :skip do
        end
      end

      context "And they have chosen an Appropriate Body for the next academic year" do
        before do
          sign_in_as school_induction_tutor

          Pages::SchoolDashboardPage.loaded
                                    .add_appropriate_body(appropriate_body.name, appropriate_body.body_type)

          sign_out
        end

        it "Then it has a school cohort with appropriate body record" do
          # to be a minimal SchoolCohort with Appropriate Body
          expect(school_cohort&.appropriate_body).to eq appropriate_body
        end

        it "And they cannot add a participant", :skip do
        end
      end
    end

    context "When they set up the next cohort with a full induction programme as the default" do
      let(:training_programme) { "full_induction_programme" }

      before do
        sign_in_as school_induction_tutor

        Pages::SchoolReportProgrammeWizard.loaded
                                          .complete(programme_type: "FIP")

        sign_out
      end

      it "Then it has a minimum school cohort record with a minimum full induction programme record" do
        # to be a School with a SchoolCohort
        expect(school.school_cohorts).to_not be_empty

        # to be a minimal SchoolCohort
        expect(school_cohort).to be_a SchoolCohort
        expect(school_cohort&.cohort).to eq current_cohort
        expect(school_cohort&.core_induction_programme).to be_nil
        expect(school_cohort&.appropriate_body).to be_nil
        expect(school_cohort&.ecf_participant_profiles).to be_empty
        expect(school_cohort&.mentor_profiles).to be_empty

        expect(school_cohort&.induction_programmes).to_not be_empty
      end

      it "And it has a minimum full induction programme record" do
        # to be a CIP SchoolCohort
        expect(school_cohort&.induction_programmes).to include default_induction_programme

        # to be a minimal InductionProgramme
        expect(default_induction_programme).to be_a InductionProgramme
        expect(default_induction_programme&.school_cohort).to eq school_cohort
        expect(default_induction_programme&.induction_records).to be_empty

        # to be a minimal Full InductionProgramme
        expect(default_induction_programme&.training_programme).to eq training_programme
        expect(default_induction_programme&.core_induction_programme).to be_nil
        expect(default_induction_programme&.partnership).to be_nil
      end

      it "And they can add a participant", :skip do
      end

      context "And they have a partnership in place for the next academic year" do
        before do
          given_i_sign_in_as_the_user_with_the_full_name lead_provider_user.full_name

          Pages::LeadProviderDashboard.loaded
                                      .confirm_schools
                                      .complete(delivery_partner.name, [school.urn])
          sign_out
        end

        it "Then it has a full induction programme with partnership record as the default" do
          # to be a FIP SchoolCohort with partnership
          expect(school_cohort&.core_induction_programme).to be_nil

          # to be a minimal Full InductionProgramme with materials
          expect(default_induction_programme&.training_programme).to eq training_programme
          expect(default_induction_programme&.core_induction_programme).to be_nil
          expect(default_induction_programme&.partnership).to_not be_nil

          # to be a minimal Partnership
          expect(partnership).to be_a Partnership
          expect(partnership&.challenge_reason).to be_nil
          expect(partnership&.challenged_at).to be_nil
          expect(partnership&.pending).to be false
          expect(partnership&.cohort).to eq current_cohort
          expect(partnership&.school).to eq school
          expect(partnership&.lead_provider).to eq lead_provider
          expect(partnership&.delivery_partner).to eq delivery_partner
        end

        it "And they can add a participant", :skip do
        end
      end

      context "And they have chosen an Appropriate Body for the next academic year" do
        before do
          sign_in_as school_induction_tutor

          Pages::SchoolDashboardPage.loaded
                                    .add_appropriate_body(appropriate_body.name, appropriate_body.body_type)

          sign_out
        end

        it "Then it has a school cohort with appropriate body record" do
          # to be a minimal SchoolCohort with Appropriate Body
          expect(school_cohort&.appropriate_body).to eq appropriate_body
        end

        it "And they can add a participant", :skip do
        end
      end
    end

    context "When they have chosen a DIY training programme for the next academic year" do
      let(:training_programme) { "design_our_own" }

      before do
        sign_in_as school_induction_tutor

        Pages::SchoolReportProgrammeWizard.loaded
                                          .complete(programme_type: "DIY")

        sign_out
      end

      it "Then it has a minimum school cohort record with a minimum DIY induction programme record" do
        # to be a School with a SchoolCohort
        expect(school.school_cohorts).to_not be_empty

        # to be a minimal SchoolCohort
        expect(school_cohort).to be_a SchoolCohort
        expect(school_cohort&.cohort).to eq current_cohort
        expect(school_cohort&.core_induction_programme).to be_nil
        expect(school_cohort&.appropriate_body).to be_nil
        expect(school_cohort&.ecf_participant_profiles).to be_empty
        expect(school_cohort&.mentor_profiles).to be_empty

        expect(school_cohort&.induction_programmes).to_not be_empty
      end

      it "And it has a minimum DIY induction programme record" do
        # to be a CIP SchoolCohort
        expect(school_cohort&.induction_programmes).to include default_induction_programme

        # to be a minimal InductionProgramme
        expect(default_induction_programme).to be_a InductionProgramme
        expect(default_induction_programme&.school_cohort).to eq school_cohort
        expect(default_induction_programme&.induction_records).to be_empty

        # to be a minimal CIP InductionProgramme
        expect(default_induction_programme&.training_programme).to eq training_programme
        expect(default_induction_programme&.core_induction_programme).to be_nil
        expect(default_induction_programme&.partnership).to be_nil
      end

      it "And they can add a participant", :skip do
      end

      context "And they have chosen an Appropriate Body for the next academic year" do
        before do
          sign_in_as school_induction_tutor

          Pages::SchoolDashboardPage.loaded
                                    .add_appropriate_body(appropriate_body.name, appropriate_body.body_type)

          sign_out
        end

        it "Then it has a school cohort with appropriate body record" do
          # to be a minimal SchoolCohort with Appropriate Body
          expect(school_cohort&.appropriate_body).to eq appropriate_body
        end

        it "And they can add a participant", :skip do
        end
      end
    end

    context "When they expect no ECTs to join in the next academic year" do
      let(:training_programme) { nil }

      before do
        sign_in_as school_induction_tutor

        Pages::SchoolReportProgrammeWizard.loaded
                                          .complete(programme_type: "NONE")

        sign_out
      end

      it "Then it has a minimum school cohort record with no induction programme record" do
        # to be a School with a SchoolCohort
        expect(school.school_cohorts).to_not be_empty

        # to be a minimal SchoolCohort
        expect(school_cohort).to be_a SchoolCohort
        expect(school_cohort&.cohort).to eq current_cohort
        expect(school_cohort&.core_induction_programme).to be_nil
        expect(school_cohort&.appropriate_body).to be_nil
        expect(school_cohort&.ecf_participant_profiles).to be_empty
        expect(school_cohort&.mentor_profiles).to be_empty

        expect(school_cohort&.induction_programmes).to be_empty
      end

      it "And it has no induction programme record" do
        # to have no default induction record
        expect(default_induction_programme).to be_nil
      end

      it "And they cannot add a participant", :skip do
      end
    end
  end

  # helper whilst debugging scenarios with --fail-fast

  def full_stop(html: false)
    links = page.all("main a").map { |link| "  -  #{link.text} href: #{link['href']}" }

    puts "==="
    puts page.current_url
    puts "---"
    if html
      puts page.html
    else
      puts page.find("main").text
    end
    puts "---\nLinks:"
    puts links
    puts "==="
    raise
  end
end
