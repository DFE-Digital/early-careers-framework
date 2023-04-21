# frozen_string_literal: true

class UpdateInductionTutorReminderJob < ApplicationJob
  def perform(school, **kwargs)
    UpdateInductionTutorReminder.new(school, **kwargs).send!
  end
end
