# frozen_string_literal: true

module DQTHelper
  def valid_dqt_response(participant_data)
    DQTRecordPresenter.new({
      "name" => participant_data[:full_name],
      "trn" => participant_data[:trn],
      "state_name" => "Active",
      "dob" => participant_data[:date_of_birth],
      "qualified_teacher_status" => { "qts_date" => 1.year.ago },
      "induction" => {
        "start_date" => participant_data.fetch(:start_date, 1.month.ago),
        "status" => "Active",
      },
    })
  end
end
