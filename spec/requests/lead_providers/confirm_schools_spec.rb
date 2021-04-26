# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead Provider confirmation of schools", type: :request do
  let(:schools) { create_list :school, rand(4..10) }
  let(:delivery_partner) { create :delivery_partner }
  let(:lead_provider_user) { create :user, :lead_provider }
  let(:lead_provider) { lead_provider_user.lead_provider }

  before do
    sign_in lead_provider_user

    set_session(:confirm_schools_form, {
      source: :csv,
      school_ids: schools.map(&:id),
      delivery_partner_id: delivery_partner.id,
    })
  end

  describe "GET /lead-providers/report-schools/confirm" do
    it "renders show template" do
      get "/lead-providers/report-schools/confirm"

      expect(response).to render_template "lead_providers/confirm_schools/show"
    end
  end

  describe "POST /lead-providers/report-schools/confirm/remove" do
    let(:school_to_remove) { schools.sample }

    it "removes given school from the list" do
      post "/lead-providers/report-schools/confirm/remove", params: { remove: { school_id: school_to_remove.id } }

      expect(session[:confirm_schools_form]["school_ids"]).not_to include school_to_remove.id
    end
  end

  describe "PUT /lead-providers/report-schools/confirm" do
    let!(:cohort) { create :cohort, :current }

    it "creates new partnerships" do
      put "/lead-providers/report-schools/confirm"

      expect(lead_provider.partnerships).to match_array(
        schools.map do |school|
          an_object_having_attributes(
            class: Partnership,
            cohort_id: cohort.id,
            school_id: school.id,
            lead_provider_id: lead_provider.id,
            delivery_partner_id: delivery_partner.id,
          )
        end,
      )
    end

    it "schedules partnership notifications" do
      put "/lead-providers/report-schools/confirm"

      schools.each do |school|
        expect(PartnershipNotificationService.new).to delay_execution_of(:notify)
          .with(an_object_having_attributes(
                  class: Partnership,
                  cohort_id: cohort.id,
                  school_id: school.id,
                  lead_provider_id: lead_provider.id,
                  delivery_partner_id: delivery_partner.id,
                ))
      end
    end
  end
end
