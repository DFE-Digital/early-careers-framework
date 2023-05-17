# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::Partnerships", type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let!(:school) { user.induction_coordinator_profile.schools.first }
  let(:cohort) { Cohort.current || create(:cohort, :current) }

  before do
    create(:school_cohort, school:, cohort:)
    sign_in user
  end

  describe "GET /schools/:school_id/cohorts/:start_year/partnerships" do
    let(:header) { "Have you signed up with a training provider?" }

    it "renders the partnerships template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/partnerships"

      expect(response).to render_template("schools/partnerships/index")
    end

    context "when the school is in a partnership" do
      let(:lead_provider) { create(:lead_provider) }
      let(:another_school) { create(:school) }
      let(:delivery_partner1) { delivery_partners.third }
      let(:delivery_partner2) { delivery_partners.fourth }
      let(:delivery_partners) { create_list(:delivery_partner, 5) }
      let!(:partnership) do
        create(:partnership,
               cohort:,
               lead_provider:,
               school:,
               delivery_partner: delivery_partner1)
      end

      before do
        create(:partnership,
               cohort:,
               lead_provider:,
               school: another_school,
               delivery_partner: delivery_partner2)

        delivery_partners.each do |partner|
          ProviderRelationship.create!(cohort:, lead_provider:, delivery_partner: partner)
        end
      end

      it "renders partnership details" do
        get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/partnerships"

        expect(response.body).to include(CGI.escapeHTML(lead_provider.name))
        expect(response.body).to include(CGI.escapeHTML(delivery_partner1.name))
        expect(response.body).to include(CGI.escapeHTML("Signed up with a training provider"))
      end

      context "when the partnership is still within its challenge window" do
        let!(:partnership) do
          create(:partnership, :in_challenge_window,
                 cohort:,
                 lead_provider:,
                 school:,
                 delivery_partner: delivery_partner1)
        end

        it "shows the challenge link" do
          get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/partnerships"

          expect(response.body).to include("This link will expire on")
          expect(response.body).to include("?partnership=#{partnership.id}")
        end
      end

      context "when the school entered a partnership a long time ago" do
        before do
          PartnershipNotificationEmail.create!(
            token: "abc123",
            sent_to: user.email,
            partnership:,
            email_type: PartnershipNotificationEmail.email_types[:induction_coordinator_email],
          )
        end

        it "does not show the challenge link" do
          travel_to 6.weeks.from_now
          get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/partnerships"

          expect(response.body).not_to include("This link will expire on")
          expect(response.body).not_to include("?token=abc123")
          expect(response.body).to include("contact: ")
        end
      end
    end
  end
end
