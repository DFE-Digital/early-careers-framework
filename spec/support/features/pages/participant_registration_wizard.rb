# frozen_string_literal: true

module Pages
  class ParticipantRegistrationWizard
    include Capybara::DSL
    include WebMock

    def complete(participant_name, year, month, day, trn)
      click_on "Continue"

      stub_request(:get, "https://dtqapi.example.com/dqt-crm/v1/teachers/#{trn}?birthdate=#{year}-#{month}-#{day}")
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
          "dob": "#{year}-#{month}-#{day}T00:00:00",
          "trn": trn,
          "ni_number": "AB123456D",
          "active_alert": false,
          "state_name": "Active",
          "qualified_teacher_status": {
            "qts_date": "2020-07-05T00:00:00Z",
          },
        }), headers: {})

      add_teacher_reference_number trn
      add_date_of_birth year, month, day
    end

    def add_teacher_reference_number(trn)
      fill_in "Teacher reference number (TRN)", with: trn
      click_on "Continue"
    end

    def add_date_of_birth(year, month, day)
      fill_in "Day", with: day
      fill_in "Month", with: month
      fill_in "Year", with: year
      click_on "Continue"
    end
  end
end
