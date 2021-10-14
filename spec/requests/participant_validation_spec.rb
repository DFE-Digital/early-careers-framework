# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Participant validations", with_feature_flags: { eligibility_notifications: "active" }, type: :request do
  before do
    sign_in user
  end

  let(:user) { profile.user }

  RSpec.shared_examples "it renders the template" do |template_name|
    it "it renders the #{template_name} page" do
      # The first request redirects to itself, no idea why
      get "/participants/validation/complete"
      get "/participants/validation/complete"
      expect(response).to render_template template_name
    end
  end

  describe "complete" do
    context "user is a cip ECT" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:profile) { create(:participant_profile, :ect, school_cohort: school_cohort) }

      it_behaves_like "it renders the template", "participants/validations/cip_ect_eligible"
    end

    context "user is a cip mentor" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:profile) { create(:participant_profile, :mentor, school_cohort: school_cohort) }

      context "user has active flags reason on their eligibility" do
        before do
          create(:ecf_participant_eligibility, :manual_check, participant_profile: profile, active_flags: true)
        end

        it_behaves_like "it renders the template", "participants/validations/cip_mentor_active_flags"
      end

      context "user doesn't have active flags reason on their eligibility" do
        it_behaves_like "it renders the template", "participants/validations/cip_mentor_eligible"
      end
    end

    context "user is a fip ECT" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:profile) { create(:participant_profile, :ect, school_cohort: school_cohort) }

      context "user is eligible" do
        before do
          create(:ecf_participant_eligibility, :eligible, participant_profile: profile)
        end

        context "user's school is in a partnership" do
          before do
            create(:partnership, school: school_cohort.school, cohort: school_cohort.cohort)
          end

          it_behaves_like "it renders the template", "participants/validations/fip_eligible_partnership"
        end

        context "user's school is not in a partnership" do
          it_behaves_like "it renders the template", "participants/validations/fip_eligible_no_partnership"
        end
      end

      context "user's trn isn't matched" do
        context "user's school is in a partnership" do
          before do
            create(:partnership, school: school_cohort.school, cohort: school_cohort.cohort)
          end

          it_behaves_like "it renders the template", "participants/validations/fip_no_trn_match_partnership"
        end

        context "user's school is not in a partnership" do
          it_behaves_like "it renders the template", "participants/validations/fip_no_trn_match_no_partnership"
        end
      end

      context "user has a previous induction" do
        before do
          create(:ecf_participant_eligibility, :manual_check, participant_profile: profile, previous_induction: true)
        end

        it_behaves_like "it renders the template", "participants/validations/fip_ect_previous_induction"
      end

      context "user has active flags" do
        before do
          create(:ecf_participant_eligibility, :manual_check, participant_profile: profile, active_flags: true)
        end

        it_behaves_like "it renders the template", "participants/validations/fip_ect_active_flags"
      end

      context "user has no qts" do
        before do
          create(:ecf_participant_eligibility, :manual_check, participant_profile: profile, qts: false)
        end

        it_behaves_like "it renders the template", "participants/validations/fip_ect_no_qts"
      end
    end

    context "user is a fip mentor" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:profile) { create(:participant_profile, :mentor, school_cohort: school_cohort) }

      context "user is eligible" do
        before do
          create(:ecf_participant_eligibility, :eligible, participant_profile: profile)
        end

        context "user's school is in a partnership" do
          before do
            create(:partnership, school: school_cohort.school, cohort: school_cohort.cohort)
          end

          it_behaves_like "it renders the template", "participants/validations/fip_eligible_partnership"
        end

        context "user's school is not in a partnership" do
          it_behaves_like "it renders the template", "participants/validations/fip_eligible_no_partnership"
        end
      end

      context "user's trn isn't matched" do
        context "user's school is in a partnership" do
          before do
            create(:partnership, school: school_cohort.school, cohort: school_cohort.cohort)
          end

          it_behaves_like "it renders the template", "participants/validations/fip_no_trn_match_partnership"
        end

        context "user's school is not in a partnership" do
          it_behaves_like "it renders the template", "participants/validations/fip_no_trn_match_no_partnership"
        end
      end

      context "user has a previous participaction" do
        before do
          create(:ecf_participant_eligibility, :manual_check, participant_profile: profile, previous_participation: true)
        end

        it_behaves_like "it renders the template", "participants/validations/fip_mentor_previous_participation"
      end

      context "user has active flags" do
        before do
          create(:ecf_participant_eligibility, :manual_check, participant_profile: profile, active_flags: true)
        end

        it_behaves_like "it renders the template", "participants/validations/fip_mentor_active_flags"
      end

      context "user has no qts" do
        before do
          create(:ecf_participant_eligibility, :manual_check, participant_profile: profile, qts: false)
        end

        it_behaves_like "it renders the template", "participants/validations/fip_mentor_no_qts"
      end
    end
  end
end
