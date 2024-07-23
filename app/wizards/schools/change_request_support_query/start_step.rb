# frozen_string_literal: true

module Schools
  module ChangeRequestSupportQuery
    class StartStep < StoredStep
      attr_writer :answer

      validates :answer, presence: {
        message: ->(object, _) { I18n.t("#{object.activemodel_error_i18n_key}.answer.blank") },
      }

      def self.permitted_params
        [:answer]
      end

      def answer
        @answer || stored_attrs[:answer]
      end

      def previous_step
        :intro
      end

      def next_step
        if answer == "yes"
          wizard.participant_change_request? ? :email : :relation
        elsif answer == "no"
          :contact_providers
        end
      end

      def activemodel_error_i18n_key
        "activemodel.errors.models.schools/#{wizard.change_request_type.underscore}/start_step.attributes"
      end
    end
  end
end
