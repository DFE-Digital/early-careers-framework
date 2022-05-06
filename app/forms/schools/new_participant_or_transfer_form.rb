# frozen_string_literal: true

module Schools
  class NewParticipantOrTransferForm
    include ActiveModel::Model

    attr_accessor :type

    validates :type,
              presence: { message: I18n.t("errors.type.blank") },
              inclusion: { in: %w[transfer ect mentor] }
  end
end
