# frozen_strin_literal: true

require 'mail/delivery_recorder'

ActionMailer::Base.register_observer(Mail::DeliveryRecorder)


class << ActionMailer::Base
  attr_accessor :record_emails
end
