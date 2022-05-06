# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class ParticipantRegistrationWizard < ::Pages::BasePage
    include WebMock::API

    set_url "ParticipantRegistrationWizard"
    set_primary_heading "ParticipantRegistrationWizard"

    def complete_for_ect(participant_name, participant_dob, trn)
      setup_response_from_dqt participant_name, participant_dob, trn

      agree_to_privacy_policy
      add_teacher_reference_number trn
      add_date_of_birth participant_dob
    end

    def complete_for_mentor(participant_name, participant_dob, trn)
      setup_response_from_dqt participant_name, participant_dob, trn

      agree_to_privacy_policy
      confirm_have_trn
      add_teacher_reference_number trn
      add_date_of_birth participant_dob
    end

    def agree_to_privacy_policy
      click_on "Continue"
    end

    def confirm_have_trn
      choose "Yes"
      click_on "Continue"
    end

    def add_teacher_reference_number(trn)
      fill_in "Teacher reference number (TRN)", with: trn
      click_on "Continue"
    end

    def add_date_of_birth(dob)
      fill_in "Day", with: dob[:day]
      fill_in "Month", with: dob[:month]
      fill_in "Year", with: dob[:year]
      click_on "Continue"
    end

    def setup_response_from_dqt(participant_name, dob, trn)
      stub_request(:get, "https://dtqapi.example.com/dqt-crm/v1/teachers/#{trn}?birthdate=#{dob[:year]}-#{dob[:month]}-#{dob[:day]}")
        .with(
          headers: {
            "Accept" => "*/*",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Authorization" => "Bearer some-apikey-guid",
            "Host" => "dtqapi.example.com",
            "User-Agent" => "Ruby",
          },
        )
        .to_return(status: 200, body: JSON.generate({
          "name": participant_name,
          "dob": "#{dob[:year]}-#{dob[:month]}-#{dob[:day]}T00:00:00",
          "trn": trn,
          "ni_number": "AB123456D",
          "active_alert": false,
          "state_name": "Active",
          "qualified_teacher_status": {
            "qts_date": "2021-07-05T00:00:00Z",
          },
          "induction": {
            "start_date": "2021-09-02T00:00:00Z",
          },
        }), headers: {})
    end
  end
end
