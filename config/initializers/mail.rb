# frozen_string_literal: true

require "mail/delivery_recorder"

Mail::DeliveryRecorder.setup!(enabled: Rails.application.config.record_emails)
