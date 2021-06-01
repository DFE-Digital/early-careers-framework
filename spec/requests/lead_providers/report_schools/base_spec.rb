# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead Provider school reporting", type: :request do
  let(:user) { create(:user, :lead_provider) }
  let!(:cohort) { create(:cohort, :current) }

  before do
    sign_in user
  end

  describe "GET /lead-providers/report-schools/start" do
    it "should show the start page to a lead provider" do
      get "/lead-providers/report-schools/start"

      expect(response).to render_template :start
    end
  end

  describe "GET /lead-providers/report-schools/success" do
    let(:schools) { create_list :school, rand(3..5) }
    let(:delivery_partner) { create :delivery_partner }

    before do
      set_session(
        LeadProviders::ReportSchools::BaseController::SESSION_KEY,
        { school_ids: schools.map(&:id), delivery_partner_id: delivery_partner.id },
      )
    end

    it "displays success message" do
      get "/lead-providers/report-schools/success"

      expect(response).to render_template :success
    end

    it "removes confirmation form from session" do
      get "/lead-providers/report-schools/success"

      expect(session).not_to have_key(:confirm_schools_form)
    end
  end

  describe "POST /lead-providers/report-schools" do
    let(:cohort) { create :cohort }
    let(:schools) { create_list(:school, rand(4..10)).shuffle }
    let(:delivery_partner) { create :delivery_partner }
    let(:lead_provider_user) { create :user, :lead_provider }
    let(:lead_provider) { lead_provider_user.lead_provider }

    before do
      set_session(LeadProviders::ReportSchools::BaseController::SESSION_KEY, {
        source: :csv,
        school_ids: schools.map(&:id),
        delivery_partner_id: delivery_partner.id,
        cohort_id: cohort.id,
        lead_provider_id: lead_provider.id,
      })
    end

    it "creates new partnerships" do
      expected_partnerships = schools.map do |school|
        an_object_having_attributes(
          class: Partnership,
          cohort_id: cohort.id,
          school_id: school.id,
          lead_provider_id: lead_provider.id,
          delivery_partner_id: delivery_partner.id,
        )
      end

      post "/lead-providers/report-schools"

      expect(lead_provider.partnerships).to match_array(expected_partnerships)
    end

    it "schedules partnership notifications" do
      post "/lead-providers/report-schools"

      schools.each do |school|
        expect(an_instance_of(PartnershipNotificationService)).to delay_execution_of(:notify)
          .with(an_object_having_attributes(
                  class: Partnership,
                  cohort_id: cohort.id,
                  school_id: school.id,
                  lead_provider_id: lead_provider.id,
                  delivery_partner_id: delivery_partner.id,
                ))
      end
    end

    context "when reporting previously challenged partnership" do
      let(:partnership) { create :partnership, :challenged, lead_provider: lead_provider, cohort: cohort }
      let(:schools) { [partnership.school] }

      it "does not create a new partnership record" do
        expect { post "/lead-providers/report-schools" }
          .not_to change(Partnership, :count)
      end

      it "unchallenges the existing partnership" do
        expect { post "/lead-providers/report-schools" and partnership.reload }
          .to change { partnership.challenged? }.from(true).to(false)
          .and change { partnership.delivery_partner }.to delivery_partner
      end
    end

    context "when a single partnership creation fails" do
      let(:failing_school) { schools.sample }

      def confirm!
        post "/lead-providers/report-schools/confirm"
      rescue StandardError # rubocop:disable Lint/SuppressedException
      end

      before do
        allow(Partnership).to receive(:create!).and_call_original
        allow(Partnership).to receive(:create!)
          .with(hash_including(school_id: failing_school.id))
          .and_raise StandardError.new(Faker::Lorem.sentence)
      end

      it "is not creating any Partnerships" do
        expect { confirm! }.not_to change(Partnership, :count)
      end

      it "schedules no partnership notifications" do
        confirm!

        expect(an_instance_of(PartnershipNotificationService)).not_to delay_execution_of(:notify)
      end
    end
  end
end
