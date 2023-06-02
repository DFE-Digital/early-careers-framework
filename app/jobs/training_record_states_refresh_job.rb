# frozen_string_literal: true

class TrainingRecordStatesRefreshJob < ApplicationJob
  def perform
    Rails.logger.info "Training record states refresh..."

    TrainingRecordState.refresh
  end
end
