# frozen_string_literal: true

FactoryBot.define do
  factory :validation_error do
    form_object {
      [
        "MentorEctsForm",
        "AppropriateBodySelectionForm",
        "Schools::TransferOutForm",
        "Schools::AddParticipants::AddWizard",
        "Schools::Cohorts::SetupWizard",
        "Participants::ParticipantValidationForm",
      ].sample
    }
    details {
      [
        { full_name: { messages: ["Enter a valid full name"], value: "JustTheName" } },
        { address: { messages: ["Enter a valid address"], value: "Address without a number" } },
        { appropriate_body: { messages: ["Choose an appropriate body"], value: "not valid AB" } },
        { start_date: { messages: ["Insert the start date"], value: "32/01/2001" } },
      ].sample
    }
    user factory: %i[user]
    request_path { "/schools" }
    created_at { Faker::Time.backward }
    updated_at { created_at }
  end
end
