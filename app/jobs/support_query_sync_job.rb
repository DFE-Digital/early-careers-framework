# frozen_string_literal: true

class SupportQuerySyncJob < ApplicationJob
  queue_as :default

  def perform(support_query)
    support_query.sync_to_support_queue
  end
end
