# frozen_string_literal: true

class TrainingRecordStatesRefreshJob < ApplicationJob
  sidekiq_options retry: false

  def perform
    Rails.logger.info "Training record states refresh..."

    TrainingRecordState.refresh
  end
end
