# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += %i[
  passw
  secret
  token
  _key
  crypt
  salt
  certificate
  otp
  ssn
  national_insurance_number
  nino
  full_name
  date_of_birth
  trn
  teacher_reference_number
]
