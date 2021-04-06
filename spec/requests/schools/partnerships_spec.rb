# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::Partnerships", type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school) { user.induction_coordinator_profile.schools.first }
  let(:cohort) { create(:cohort, start_year: 2021) }

  before do
    school
    sign_in user
  end

  describe "GET /schools/cohorts/:start_year/partnerships" do
    let(:header) { "You need to sign a contract with a training provider so they can deliver your programme" }

    it "renders the partnerships template" do
      get "/schools/cohorts/#{cohort.start_year}/partnerships"

      expect(response).to render_template("schools/partnerships/index")
      expect(response.body).to include(CGI.escapeHTML(header))
    end

    context "when the school is in a partnership" do
      let(:delivery_partner) { create(:delivery_partner) }
      let(:lead_provider) { create(:lead_provider) }

      before do
        Partnership.create!(cohort: cohort, lead_provider: lead_provider, school: school)
        ProviderRelationship.create!(cohort: cohort, lead_provider: lead_provider, delivery_partner: delivery_partner)
      end

      it "renders partnership details" do
        get "/schools/cohorts/#{cohort.start_year}/partnerships"

        expect(response.body).to include(CGI.escapeHTML(lead_provider.name))
        expect(response.body).to include(CGI.escapeHTML(delivery_partner.name))
      end
    end
  end
end
