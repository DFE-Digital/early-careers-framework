# frozen_string_literal: true

class ParticipantStartTermForm
  include ActiveModel::Model

  attr_accessor :start_term, :profile

  validates :start_term,
            presence: { message: I18n.t("errors.start_term.blank") }
end
