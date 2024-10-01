# frozen_string_literal: true

RSpec.describe "Schools::EarlyCareerTeachers", type: :request, js: true, with_feature_flags: { eligibility_notifications: "active" }, early_in_cohort: true do
  let(:user) { create(:user, :induction_coordinator, school_ids: [school.id]) }
  let!(:lead_provider) { create(:cpd_lead_provider, :with_lead_provider, name: "Lead Provider").lead_provider }

  let(:school) { school_cohort.school }
  let(:cohort) { Cohort.current }

  let!(:school_cohort) { create(:school_cohort, :fip, :with_induction_programme, cohort:, lead_provider:) }
  let!(:another_cohort) { create(:school_cohort) }

  let(:mentor_profile) { create(:mentor, school_cohort:, lead_provider:) }
  let!(:mentor_user) { mentor_profile.user }

  let!(:mentor_profile_2) { create(:mentor, school_cohort:, lead_provider:) }
  let!(:mentor_user_2) { mentor_profile_2.user }

  let(:ect_profile) { create(:ect, mentor_profile_id: mentor_profile.id, school_cohort:, lead_provider:) }
  let!(:ect_user) { ect_profile.user }
  let!(:withdrawn_ect) { create(:ect, :withdrawn_record, school_cohort:, lead_provider:).user }

  let!(:unrelated_mentor_profile) { create(:mentor, school_cohort: another_cohort, lead_provider:) }
  let!(:unrelated_mentor) { unrelated_mentor_profile.user }

  let!(:unrelated_ect) { create(:ect, school_cohort: another_cohort, lead_provider:).user }
  let!(:delivery_partner) { create(:delivery_partner, name: "Delivery Partner") }
  let(:deliver_partner) { school.deliver_partner_for(cohort.start_year) }

  before do
    sign_in user
  end

  describe "GET /schools/:school_id/early_career_teachers" do
    it "renders participants template" do
      get "/schools/#{school.slug}/early_career_teachers"

      expect(response).to render_template("schools/early_career_teachers/index")
    end

    it "renders participant details" do
      get "/schools/#{school.slug}/early_career_teachers"

      expect(response.body).to include(CGI.escapeHTML(ect_user.full_name))
      expect(response.body).to include(CGI.escapeHTML(mentor_user.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(unrelated_mentor.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(unrelated_ect.full_name))
    end

    it "renders participant details when they have been withdrawn by the provider" do
      ect_profile.training_status_withdrawn!
      get "/schools/#{school.slug}/early_career_teachers"

      expect(response).to render_template("schools/early_career_teachers/index")
      expect(response.body).to include(CGI.escapeHTML(ect_user.full_name))
    end

    it "does not list participants with withdrawn profile records" do
      get "/schools/#{school.slug}/early_career_teachers"

      expect(response.body).not_to include(CGI.escapeHTML(withdrawn_ect.full_name))
    end
  end

  describe "GET /schools/:school_id/early_career_teachers/:id" do
    it "renders participant template" do
      get "/schools/#{school.slug}/early_career_teachers/#{ect_profile.id}"

      expect(response).to render_template("schools/early_career_teachers/show")
    end

    it "renders participant details" do
      get "/schools/#{school.slug}/early_career_teachers/#{ect_profile.id}"

      expect(response.body).to include(CGI.escapeHTML(ect_user.full_name))
      expect(response.body).to include(CGI.escapeHTML(mentor_user.full_name))
    end

    context "when the participant is an ECT" do
      before do
        ect_profile.current_induction_record.update!(mentor_profile: mentor_profile_2)
      end

      it "uses the mentor from the induction record" do
        get "/schools/#{school.slug}/early_career_teachers/#{ect_profile.id}"
        expect(assigns(:mentor_profile)).to eq mentor_profile_2
      end

      context "when there are mentors in the pool" do
        it "mentors_added is true" do
          get "/schools/#{school.slug}/early_career_teachers/#{ect_profile.id}"
          expect(assigns(:mentors_added)).to be true
        end
      end

      context "when there are no mentors in the pool" do
        let!(:school_mentors) { [mentor_profile, mentor_profile_2, unrelated_mentor_profile] }
        before do
          school_mentors.each do |mentor|
            Mentors::RemoveFromSchool.call(mentor_profile: mentor, school:)
          end
        end

        it "mentors_added is false" do
          get "/schools/#{school.slug}/early_career_teachers/#{ect_profile.id}"
          expect(assigns(:mentors_added)).to be false
        end
      end
    end
  end
end
