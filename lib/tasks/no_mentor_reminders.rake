# frozen_string_literal: true

namespace :no_mentor_reminders do
  desc "Send reminder to all SITs whose school has at least one ECT with no mentor associated"
  task send: :environment do
    Schools::WithEctsWithNoMentorQuery.call.each do |school, ects|
      SchoolMailer.remind_sit_to_set_mentor_to_ects(
        sit: school.induction_coordinators.first,
        ect_names: ects.map(&:full_name),
      ).deliver_later
    end
  end
end
