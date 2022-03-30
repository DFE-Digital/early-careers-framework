# frozen_string_literal: true

require "rails_helper"

require_relative "../../../shared/context/service_record_declaration_params"
require_relative "../../../shared/context/lead_provider_profiles_and_courses"

RSpec.describe RecordDeclarations::Started::NPQ do
  include_context "lead provider profiles and courses"
  include_context "service record declaration params"

  let(:cutoff_start_datetime) { npq_profile.schedule.milestones.first.start_date.beginning_of_day + 2.minutes }
  let(:cutoff_end_datetime) { npq_profile.schedule.milestones.first.milestone_date.end_of_day }

  before do
    travel_to cutoff_start_datetime + 2.days
  end

  it_behaves_like "a participant declaration without evidence held service" do
    def given_params
      npq_params
    end

    def given_profile
      npq_profile
    end
  end

  it_behaves_like "a participant service for npq" do
    def given_params
      npq_params
    end
  end
end
