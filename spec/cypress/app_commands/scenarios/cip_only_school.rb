# frozen_string_literal: true

School.find_or_create_by!(urn: "181989") do |school|
  school.name = "CIP only school"
  school.postcode = "XM4 5HQ"
  school.address_line1 = "North pole"
  school.primary_contact_email = "cip-only-school-info@example.com"
  school.school_status_code = 1
  school.school_type_code = 10
end
