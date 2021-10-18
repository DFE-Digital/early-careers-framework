# frozen_string_literal: true

class ApplicationMailer < Mail::Notify::Mailer
private

  def blank_allowed(value)
    value.presence || Mail::Notify::Personalisation::BLANK
  end
end
