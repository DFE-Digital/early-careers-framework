# frozen_string_literal: true

RSpec.describe "Schools::Participants", type: :request, js: true, with_feature_flags: { eligibility_notifications: "active" } do
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

  describe "GET /schools/:school_id/mentors" do
    it "renders participants template" do
      get "/schools/#{school.slug}/mentors"

      expect(response).to render_template("schools/mentors/index")
    end

    it "renders participant details" do
      get "/schools/#{school.slug}/mentors"

      expect(response.body).to include(CGI.escapeHTML(ect_user.full_name))
      expect(response.body).to include(CGI.escapeHTML(mentor_user.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(unrelated_mentor.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(unrelated_ect.full_name))
    end
  end

  describe "GET /schools/:school_id/mentors/:id" do
    it "renders participant template" do
      get "/schools/#{school.slug}/mentors/#{mentor_profile.id}"

      expect(response).to render_template("schools/mentors/show")
    end

    it "renders participant details" do
      get "/schools/#{school.slug}/mentors/#{mentor_profile.id}"

      expect(response.body).to include(CGI.escapeHTML(mentor_user.full_name))
    end
  end
end
