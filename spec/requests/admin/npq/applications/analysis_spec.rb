# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::NPQ::Applications::Analysis", type: :request do
  let!(:admin_user) { create :user, :admin }

  let!(:cohort) { create :cohort }
  let!(:schedule) { create :npq_leadership_schedule, cohort: }
  let(:npq_course) { create :npq_course, identifier: "npq-senior-leadership" }
  let(:npq_lead_provider) { create :npq_lead_provider }

  let!(:accepted_application) do
    npq_application = create(:npq_application, :accepted,
                             npq_lead_provider:,
                             npq_course:,
                             cohort:)

    npq_application
  end
  let!(:accepted_application_with_payment) do
    npq_application = create(:npq_application, :accepted,
                             npq_lead_provider:,
                             npq_course:,
                             cohort:)

    create(:npq_participant_declaration,
           declaration_type: "started",
           user: npq_application.user,
           participant_profile: npq_application.profile,
           course_identifier: npq_course.identifier,
           state: "paid")

    npq_application
  end

  let!(:rejected_application) do
    npq_application = create(:npq_application, :rejected,
                             npq_lead_provider:,
                             npq_course:,
                             cohort:)

    create(:npq_participant_profile)

    npq_application
  end
  let!(:rejected_application_with_payment) do
    npq_application = create(:npq_application, :rejected,
                             npq_lead_provider:,
                             npq_course:,
                             cohort:)

    participant_profile = create(:npq_participant_profile, npq_application:)

    create(:npq_participant_declaration,
           declaration_type: "started",
           user: npq_application.user,
           participant_profile:,
           course_identifier: npq_course.identifier,
           state: "paid")

    npq_application
  end
  let!(:rejected_application_with_payable) do
    npq_application = create(:npq_application, :rejected,
                             npq_lead_provider:,
                             npq_course:,
                             cohort:)

    participant_profile = create(:npq_participant_profile, npq_application:)

    create(:npq_participant_declaration,
           declaration_type: "started",
           user: npq_application.user,
           participant_profile:,
           course_identifier: npq_course.identifier,
           state: "payable")

    npq_application
  end

  before do
    sign_in admin_user
  end

  describe "GET /admin/npq/applications/analysis" do
    it "renders the index template for payments made against invalid NPQ applications" do
      get "/admin/npq/applications/analysis"
      expect(response).to render_template "admin/npq/applications/analysis/invalid_payments_analysis"
    end

    it "includes applications with invalid applications" do
      get "/admin/npq/applications/analysis"

      expect(assigns(:applications)).to include rejected_application_with_payment
      expect(assigns(:applications)).to include rejected_application_with_payable
    end

    it "does not include applications that are valid" do
      get "/admin/npq/applications/analysis"

      expect(assigns(:applications)).not_to include accepted_application_with_payment
    end

    it "does not include applications that have no associated payments" do
      get "/admin/npq/applications/analysis"

      expect(assigns(:applications)).not_to include accepted_application
      expect(assigns(:applications)).not_to include rejected_application
    end
  end
end
