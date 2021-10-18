# frozen_string_literal: true

class ApplicationMailer < Mail::Notify::Mailer
private

  def blank
    Mail::Notify::Personalisation::BLANK
  end
end
