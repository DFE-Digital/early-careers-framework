# frozen_string_literal: true

module Schools
  module ChangeRequestSupportQuery
    class RelationStep < StoredStep
      attr_writer :relation_id

      validates :relation_id, presence: {
        message: ->(object, _) { I18n.t("#{object.activemodel_error_i18n_key}.relation_id.blank") },
      }

      def self.permitted_params
        [:relation_id]
      end

      def relation_id
        @relation_id || stored_attrs[:relation_id]
      end

      def previous_step
        wizard.participant_change_request? ? :email : :start
      end

      def next_step
        :check_your_answers
      end

      def activemodel_error_i18n_key
        "activemodel.errors.models.schools/#{wizard.change_request_type.underscore}/relation_step.attributes"
      end
    end
  end
end
