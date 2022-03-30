class ParticipantStartTermForm
  include ActiveModel::Model

  attr_accessor :start_term

  validates :start_term,
            presence: { message: I18n.t("errors.start_term.blank") },
            inclusion: { in: ParticipantProfile::ECF::CURRENT_START_TERM_OPTIONS }
end
