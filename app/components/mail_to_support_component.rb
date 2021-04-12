# frozen_string_literal: true

class MailToSupportComponent < ViewComponent::Base
  def initialize(text = nil)
    @text = text
  end
end
