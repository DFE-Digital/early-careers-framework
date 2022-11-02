# frozen_string_literal: true

module ParticipantDeclarationSteps
  include Capybara::DSL

  def given_an_early_career_teacher_has_been_entered_onto_the_dfe_service
    cohort = Cohort.current
    school_cohort = create(:school_cohort, cohort:)
    @ect_profile = create(:ect_participant_profile, school_cohort:)
    delivery_partner = create(:delivery_partner)
    partnership = create(
      :partnership,
      school: @ect_profile.school,
      lead_provider: @cpd_lead_provider.lead_provider,
      cohort:,
      delivery_partner:,
    )
    induction_programme = create(:induction_programme, partnership:)
    Induction::Enrol.call(participant_profile: @ect_profile, induction_programme:)
    @ect_id = @ect_profile.user.id
    @declaration_date = @ect_profile.schedule.milestones.first.start_date + 1.day
    @submission_date = @ect_profile.schedule.milestones.first.start_date + 2.days
  end

  def given_an_ecf_mentor_has_been_entered_onto_the_dfe_service
    cohort = Cohort.current
    school_cohort = create(:school_cohort, cohort:)
    partnership = create(:partnership, lead_provider: @lead_provider, cohort:, school: school_cohort.school)
    @mentor_profile = create(:mentor_participant_profile, school: partnership.school, cohort: partnership.cohort)
    @mentor_id = @mentor_profile.user.id
    induction_programme = create(:induction_programme, partnership:)
    Induction::Enrol.call(participant_profile: @mentor_profile, induction_programme:)

    @declaration_date = @mentor_profile.schedule.milestones.first.start_date + 1.day
    @submission_date = @mentor_profile.schedule.milestones.first.start_date + 2.days
  end

  def given_an_npq_participant_has_been_entered_onto_the_dfe_service
    cohort = Cohort.current
    create(:npq_leadership_schedule)
    npq_lead_provider = create(:npq_lead_provider, cpd_lead_provider: @cpd_lead_provider)
    npq_course = create(:npq_course, identifier: "npq-senior-leadership")
    @npq_application = create(:npq_application, npq_lead_provider:, npq_course:, cohort:)
    @npq_id = @npq_application.user.id

    NPQ::Application::Accept.new(npq_application: @npq_application).call
    @declaration_date = @npq_application.reload.profile.schedule.milestones.first.start_date + 1.day
    @submission_date = @npq_application.profile.schedule.milestones.first.start_date + 2.days
  end

  def when_the_participant_details_are_passed_to_the_lead_provider
    @session.get("/api/v1/participants/ecf",
                 headers: { "Authorization": "Bearer #{@token}" })

    @participant_id = JSON.parse(@session.response.body)["data"].map { |participant| participant["id"] }.sample
    expect(@participant_id).to eq([@ect_id, @mentor_id].compact.first)
  end

  def when_the_npq_participant_details_are_passed_to_the_lead_provider
    @session.get("/api/v1/npq-applications",
                 headers: { "Authorization": "Bearer #{@token}" })

    participant = JSON.parse(@session.response.body).dig("data", 0, "attributes", "participant_id")
    expect(participant).to eq(@npq_id)
  end

  def and_the_lead_provider_submits_a_declaration_for_the_ect_using_their_id
    params = common_params(participant_id: @ect_id, course_identifier: "ecf-induction", declaration_date: @declaration_date)
    travel_to @submission_date do
      @declaration_id = submit_request(params).dig("data", "id")
    end
  end

  def and_the_lead_provider_submits_a_declaration_for_the_mentor_using_their_id
    params = common_params(participant_id: @mentor_id, course_identifier: "ecf-mentor", declaration_date: @declaration_date)
    travel_to @submission_date do
      @declaratioh_id = submit_request(params).dig("data", "id")
    end
  end

  def and_the_lead_provider_submits_a_declaration_for_the_npq_using_their_id
    params = common_params(participant_id: @npq_id, course_identifier: "npq-senior-leadership", declaration_date: @declaration_date)
    travel_to @submission_date do
      submit_request(params)
    end
  end

  def and_the_lead_provider_submits_a_declaration_for_the_participant_using_an_invalid_participant_id
    params = common_params(participant_id: "111-222-333-444-555", declaration_date: @declaration_date)
    travel_to @submission_date do
      submit_request(params)
    end
  end

  def and_the_lead_provider_submits_a_declaration_without_participant_id
    params = common_params(participant_id: "", declaration_date: @declaration_date)
    params["data"]["attributes"].reject! { |a| a["participant_id"] }
    travel_to @submission_date do
      submit_request(params)
    end
  end

  def and_the_lead_provider_voids_a_declaration
    travel_to @submission_date + 2.days do
      @session.put("/api/v1/participant-declarations/#{@declaration_id}/void", headers: { "Authorization": "Bearer #{@token}" })
    end
  end

  def then_the_declaration_made_is_valid
    expect(ParticipantDeclaration.find(@response["data"]["id"])).to be_present
  end

  def and_schedule_change_is_submitted_for_this_participant
    @session.put("/api/v1/participants/#{@ect_id}/change-schedule", headers: { "Authorization": "Bearer #{@token}" })
  end

  def and_lead_provider_changed_for_the_participant
    partnership = Partnership.where(school: @ect_profile.school, lead_provider: @cpd_lead_provider.lead_provider).first

    @new_lead_provider = create(:lead_provider)
    @new_cpd_lead_provider = create(:cpd_lead_provider, lead_provider: @new_lead_provider)

    delivery_partner = create(:delivery_partner)

    new_partnership = create(
      :partnership,
      school: @ect_profile.school,
      lead_provider: @new_cpd_lead_provider.lead_provider,
      cohort: partnership.cohort,
      delivery_partner:,
    )

    new_induction_programme = create(:induction_programme, partnership: new_partnership)
    @ect_profile.induction_records.first.leaving!
    Induction::Enrol.call(participant_profile: @ect_profile, induction_programme: new_induction_programme)
  end

  def then_one_declaration_is_created
    expect(ParticipantDeclaration.where(course_identifier: "ecf-induction", declaration_type: "started", state: "submitted").count).to eq(1)
  end

  def then_second_declaration_is_not_created
    expect(ParticipantDeclaration.count).to eq(1)
  end

  def and_the_npq_declaration_date_is_early
    @declaration_date = @npq_application.reload.profile.schedule.milestones.where(declaration_type: "started").first.start_date - 1.day
  end

  def and_the_ect_declaration_date_is_early
    @declaration_date = @ect_profile.schedule.milestones.first.start_date - 1.day
  end

  def and_the_ect_declaration_date_is_late
    @declaration_date = @ect_profile.schedule.milestones.first.milestone_date + 1.day
  end

  def and_the_mentor_declaration_date_is_early
    @declaration_date = @mentor_profile.schedule.milestones.first.start_date - 1.day
  end

  def and_the_mentor_declaration_date_is_late
    @declaration_date = @mentor_profile.schedule.milestones.first.milestone_date + 1.day
  end

  def then_the_declaration_made_is_invalid
    expect(@response["errors"]).not_to be_empty
  end

  def and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_was_successful
    expect(@response_http_code).to eq(200)
  end

  def and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_has_a_validation_error
    expect(@response_http_code).to eq(422)
  end

  def and_the_provider_withdraws_a_participant
    params = {
      "data" => {
        "type" => "participant-declaration",
        "attributes" => {
          "reason" => "left-teaching-profession",
          "course_identifier" => "ecf-induction",
        },
      },
    }
    travel_to @submission_date + 1.day do
      @session.put("/api/v1/participants/#{@participant_id}/withdraw",
                   params:,
                   headers: { "Authorization": "Bearer #{@token}" })
    end
  end

  def then_the_declaration_made_against_the_withdrawn_participant_is_still_accepted
    params = common_params(participant_id: @participant_id, declaration_date: @declaration_date + 1.day)
    travel_to @submission_date + 2.days do
      submit_request(params)
    end
    expect(@response.dig("errors", 0, "detail")).to eq(nil)
  end

  def submit_request(params)
    @response_http_code = @session.post("/api/v1/participant-declarations",
                                        params:,
                                        headers: { "Authorization": "Bearer #{@token}" })
    @response = JSON.parse(@session.response.body)
  end

  def setup
    @lead_provider = create(:lead_provider)
    @cpd_lead_provider = create(:cpd_lead_provider, lead_provider: @lead_provider)
    @statement = create(:ecf_statement, cpd_lead_provider: @cpd_lead_provider)
    @token = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: @cpd_lead_provider)
    @session = ActionDispatch::Integration::Session.new(Rails.application)
  end

  def common_params(participant_id:, declaration_date:, course_identifier: "ecf-induction")
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
