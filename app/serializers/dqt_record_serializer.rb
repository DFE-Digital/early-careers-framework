# frozen_string_literal: true

class DqtRecordSerializer
  include JSONAPI::Serializer

  set_id :teacher_reference_number
  attributes :teacher_reference_number, :full_name, :date_of_birth, :national_insurance_number, :qts_date, :active_alert
end
