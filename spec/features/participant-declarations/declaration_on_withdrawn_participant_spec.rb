# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Declaration on withdrawn participant", type: :feature do
  before(:each) do
    setup
  end

  scenario "Withdraw a participant and submit a declaration" do
    given_an_early_career_teacher_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    withdraw_one_participant
    then_the_declaration_made_is_rejected
  end

private

  def setup
    @lead_provider = create(:lead_provider)
    @cpd_lead_provider = create(:cpd_lead_provider, lead_provider: @lead_provider)
    @token = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: @cpd_lead_provider)
    @session = ActionDispatch::Integration::Session.new(Rails.application)
  end

  def given_an_early_career_teacher_has_been_entered_onto_the_dfe_service
    @ect_profile = create(:participant_profile, :ect)
    delivery_partner = create(:delivery_partner)
    create(:partnership,
           school: @ect_profile.school,
           lead_provider: @cpd_lead_provider.lead_provider,
           cohort: @ect_profile.cohort,
           delivery_partner: delivery_partner)

    @ect_id = @ect_profile.user.id
    travel_to @ect_profile.schedule.milestones.first.start_date + 1.day
  end

  def when_the_participant_details_are_passed_to_the_lead_provider
    @session.get("/api/v1/participants",
                 headers: { "Authorization": "Bearer #{@token}" })

    @participant_id = JSON.parse(@session.response.body).dig("data").map { |participant| participant["id"] }.sample
  end

  def withdraw_one_participant
    travel_to @ect_profile.schedule.milestones.first.start_date + 2.hours

    params = {
      "data" => {
        "type" => "participant-declaration",
        "attributes" => {
          "reason" => "career-break",
          "course_identifier" => "ecf-induction",
        },
      },
    }
    @session.put("/api/v1/participants/#{@participant_id}/withdraw",
                 params: params,
                 headers: { "Authorization": "Bearer #{@token}" })
  end

  def then_the_declaration_made_is_rejected
    travel_to @ect_profile.schedule.milestones.first.start_date + 3.hours

    params = common_params(@participant_id, "ecf-induction")
    submit_request(params)

    expect(@response.dig("errors", 0, "detail")).to eq("The declaration on withdrawn or deferred participant can not be accepted")
  end

  def submit_request(params)
    @response_http_code = @session.post("/api/v1/participant-declarations",
                                        params: params,
                                        headers: { "Authorization": "Bearer #{@token}" })
    @response = JSON.parse(@session.response.body)
  end

  def common_params(participant_id, course_identifier = "ecf-induction", declaration_date = Time.zone.now)
    JSON.parse(<<~DATA)
      {
      "data":{
        "type":"participant-declaration",
        "attributes": {
           "participant_id": "#{participant_id}",
           "declaration_type": "started",
           "declaration_date": "#{declaration_date.rfc3339}",
      		 "course_identifier": "#{course_identifier}"
         }
       }
      }
    DATA
  end
end
