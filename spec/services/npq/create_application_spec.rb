# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::CreateApplication do
  let!(:user) { create(:user) }
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:npq_course) { create(:npq_course) }
  let(:npq_application) { build(:npq_application, npq_course: npq_course, npq_lead_provider: npq_lead_provider) }
  let(:nino) { SecureRandom.hex }
  let(:npq_application_params)  do
    {
      active_alert: true,
      date_of_birth: npq_application.date_of_birth,
      eligible_for_funding: true,
      funding_choice: npq_application.funding_choice,
      headteacher_status: npq_application.headteacher_status,
      nino: nino,
      school_urn: npq_application.school_urn,
      school_ukprn: npq_application.school_ukprn,
      teacher_reference_number: npq_application.teacher_reference_number,
      teacher_reference_number_verified: true,
    }
  end
  let(:npq_course_params)       { npq_course.id }
  let(:npq_lead_provider_param) { npq_lead_provider.id }

  it "creates an application" do
    NPQ::CreateApplication.call(
      npq_application_params: npq_application_params,
      npq_course_params: npq_course_params,
      npq_lead_provider_param: npq_lead_provider_param,
      user_params: user_params,
    )
    expect(user.npq_applications.where(npq_application_params)).to exist
  end
end
