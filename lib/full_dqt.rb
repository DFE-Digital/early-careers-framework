# frozen_string_literal: true

require "full_dqt/client"
require "full_dqt/search"
require "full_dqt/record"

module FullDQT
  def self.magic_record(trn:, full_name:, date_of_birth:, nino:,
                        active_alert: false,
                        qts_date: 2.years.ago,
                        induction_start_date: 1.month.ago)
    props = {
      "trn" => TeacherReferenceNumber.new(trn).formatted_trn,
      "name" => full_name,
      "dob" => date_of_birth,
      "ni_number" => nino,
      "active_alert" => active_alert,
      "state_name" => "Active",
      "qualified_teacher_status" => {
        "qts_date" => qts_date,
      },
    }

    if induction_start_date
      props.merge!("induction" => {
        "start_date" => induction_start_date,
        "status" => "In Progress",
      })
    end

    Record.new(props)
  end
end
