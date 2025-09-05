# frozen_string_literal: true

class MailToSupportComponent < ApplicationComponent
  def initialize(text = nil)
    @text = text
  end
end
