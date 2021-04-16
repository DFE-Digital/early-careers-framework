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
    let(:header) { "Have you confirmed which training provider your school is using?" }

    it "renders the partnerships template" do
      get "/schools/cohorts/#{cohort.start_year}/partnerships"

      expect(response).to render_template("schools/partnerships/index")
      expect(response.body).to include(CGI.escapeHTML(header))
    end

    context "when the school is in a partnership" do
      let(:lead_provider) { create(:lead_provider) }
      let(:another_school) { create(:school) }
      let(:delivery_partner1) { delivery_partners.third }
      let(:delivery_partner2) { delivery_partners.fourth }
      let(:delivery_partners) { create_list(:delivery_partner, 5) }

      before do
        Partnership.create!(cohort: cohort, lead_provider: lead_provider, school: school, delivery_partner: delivery_partner1)
        Partnership.create!(cohort: cohort, lead_provider: lead_provider, school: another_school, delivery_partner: delivery_partner2)

        delivery_partners.each do |partner|
          ProviderRelationship.create!(cohort: cohort, lead_provider: lead_provider, delivery_partner: partner)
        end
      end

      it "renders partnership details" do
        get "/schools/cohorts/#{cohort.start_year}/partnerships"

        expect(response.body).to include(CGI.escapeHTML(lead_provider.name))
        expect(response.body).to include(CGI.escapeHTML(delivery_partner1.name))
        expect(response.body).to include(CGI.escapeHTML("Confirmed your training provider"))
      end
    end
  end
end
