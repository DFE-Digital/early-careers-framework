# frozen_string_literal: true

module Schools
  module ChangeRequestSupportQuery
    class EmailStep < StoredStep
      attr_writer :answer, :email

      validates :answer, presence: {
        message: ->(object, _) { I18n.t("#{object.activemodel_error_i18n_key}.answer.blank") },
      }
      validates :email, presence: {
        message: ->(object, _) { I18n.t("#{object.activemodel_error_i18n_key}.email.blank") },
      }, if: -> { answer == "no" }

      def self.permitted_params
        %i[answer email]
      end

      def answer
        @answer || stored_attrs[:answer]
      end

      def email
        @email || stored_attrs[:email]
      end

      def previous_step
        :start
      end

      def next_step
        :relation
      end

      def activemodel_error_i18n_key
        "activemodel.errors.models.schools/#{wizard.change_request_type.underscore}/email_step.attributes"
      end
    end
  end
end
