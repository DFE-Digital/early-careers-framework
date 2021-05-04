# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead Provider confirmation of schools", type: :request do
  let(:cohort) { create :cohort, :current }
  let(:schools) { create_list(:school, rand(4..10)).shuffle }
  let(:delivery_partner) { create :delivery_partner }
  let(:lead_provider_user) { create :user, :lead_provider }
  let(:lead_provider) { lead_provider_user.lead_provider }

  before do
    sign_in lead_provider_user

    set_session(:confirm_schools_form, {
      source: :csv,
      school_ids: schools.map(&:id),
      delivery_partner_id: delivery_partner.id,
      cohort_id: cohort.id,
      lead_provider_id: lead_provider.id,
    })
  end

  describe "GET /lead-providers/report-schools/confirm" do
    it "renders show template" do
      get "/lead-providers/report-schools/confirm"

      expect(response).to render_template "lead_providers/confirm_schools/show"
    end

    it "preserves the order of schools" do
      get "/lead-providers/report-schools/confirm"

      expect(assigns(:schools).map(&:id)).to eq schools.map(&:id)
    end
  end

  describe "POST /lead-providers/report-schools/confirm/remove" do
    let(:school_to_remove) { schools.sample }

    it "removes given school from the list" do
      post "/lead-providers/report-schools/confirm/remove", params: { remove: { school_id: school_to_remove.id } }

      expect(session[:confirm_schools_form]["school_ids"]).not_to include school_to_remove.id
    end

    it "sets the success flash message" do
      post "/lead-providers/report-schools/confirm/remove", params: { remove: { school_id: school_to_remove.id } }

      expect(flash[:success]).to be_present
    end
  end

  describe "POST /lead-providers/report-schools/confirm" do
    let!(:cohort) { create :cohort, :current }

    it "creates new partnerships" do
      post "/lead-providers/report-schools/confirm"

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
      post "/lead-providers/report-schools/confirm"

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
