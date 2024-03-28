# frozen_string_literal: true

class Admin::EmailSchedulesJob < ApplicationJob
  def perform
    Admin::DailyEmailSchedulesProcessor.call
  end
end
