# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead Provider confirmation of schools", type: :request do
  let(:cohort) { create :cohort, :current }
  let(:schools) { create_list(:school, rand(4..10)).shuffle }
  let(:delivery_partner) { create :delivery_partner }
  let(:lead_provider_user) { create :user, :lead_provider }
  let(:lead_provider) { lead_provider_user.lead_provider }

  subject { response }

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
    before do
      get "/lead-providers/report-schools/confirm"
    end

    context "with some pre-selected schools" do
      it { is_expected.to render_template "lead_providers/confirm_schools/show" }

      it "preserves the order of schools" do
        expect(assigns(:schools).map(&:id)).to eq schools.map(&:id)
      end
    end

    context "when the list of pre-selected schools is empty" do
      let(:schools) { [] }

      it { is_expected.to render_template "lead_providers/confirm_schools/no_schools" }
    end
  end

  describe "POST /lead-providers/report-schools/confirm/remove" do
    let(:school_to_remove) { schools.sample }

    before do
      post "/lead-providers/report-schools/confirm/remove", params: { remove: { school_id: school_to_remove.id } }
    end

    it "removes given school from the list" do
      expect(session[:confirm_schools_form]["school_ids"]).not_to include school_to_remove.id
    end

    it "displayes appropriate flash message" do
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

    # TODO: ECF-RP-564: reenable
    xit "schedules partnership notifications" do
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
