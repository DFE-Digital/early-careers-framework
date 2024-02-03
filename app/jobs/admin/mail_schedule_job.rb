# frozen_string_literal: true

class Admin::MailScheduleJob < ApplicationJob
  def perform
    Admin::DailyEmailSchedulesProcessor.call
  end
end
