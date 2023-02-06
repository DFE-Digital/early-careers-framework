# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class ParticipantRegistrationWizard < ::Pages::BasePage
    include WebMock::API

    set_url "/participants/validation/trn"
    set_primary_heading "What’s your teacher reference number (TRN)?"

    def complete_for_ect(full_name, date_of_birth, trn)
      setup_response_from_dqt full_name, date_of_birth, trn

      add_teacher_reference_number full_name, trn
      add_date_of_birth date_of_birth
    end

    def complete_for_mentor(full_name, date_of_birth, trn)
      setup_response_from_dqt full_name, date_of_birth, trn

      confirm_have_trn
      add_teacher_reference_number full_name, trn
      add_date_of_birth date_of_birth
    end

    def confirm_have_trn
      choose "Yes"
      click_on "Continue"

      self
    end

    def confirm_do_not_have_trn
      choose "No"
      click_on "Continue"

      self
    end

    def add_teacher_reference_number(_full_name, trn)
      fill_in "What’s your teacher reference number (TRN)", with: trn
      click_on "Continue"

      self
    end

    def add_date_of_birth(date_of_birth)
      fill_in "Day", with: date_of_birth.day
      fill_in "Month", with: date_of_birth.month
      fill_in "Year", with: date_of_birth.year
      click_on "Continue"

      self
    end

    def choose_add_your_national_insurance_number
      click_on "Enter your National Insurance number"

      self
    end

    def add_national_insurance_number(nino)
      fill_in "National Insurance Number", with: nino
      click_on "Continue"

      self
    end

    def choose_confirm_your_name
      click_on "Enter your name"

      self
    end

    def choose_last_name_has_changed
      choose "No"
      click_on "Continue"

      self
    end

    def add_full_name(full_name)
      fill_in "What was your full name when you started your ITT?", with: full_name
      click_on "Continue"

      self
    end

    def setup_response_from_dqt(participant_name, dob, trn)
      birth_date = "#{dob.year}-#{sprintf('%02i', dob.month)}-#{sprintf('%02i', dob.day)}"
      stub_request(:get, "https://dtqapi.example.com/dqt-crm/v1/teachers/#{trn}?birthdate=#{birth_date}")
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
          "dob": "#{birth_date}T00:00:00",
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

      self
    end
  end
end
