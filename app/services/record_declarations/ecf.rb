# frozen_string_literal: true

module RecordDeclarations
  module ECF
    extend ActiveSupport::Concern

    included do
      extend ECFClassMethods
      validate :validate_backdated_declaration_before_induction_record_end_date
    end

    def validate_backdated_declaration_before_induction_record_end_date
      potential_previous_induction_record = user_profile.relevant_induction_record(lead_provider: cpd_lead_provider.lead_provider)

      return if user_profile.current_induction_record == potential_previous_induction_record

      if potential_previous_induction_record.end_date < parsed_date
        errors.add(:declaration_date, I18n.t(:i_need_content_for_this))
      end
    end

    module ECFClassMethods
      def declaration_model
        ParticipantDeclaration::ECF
      end
    end
  end
end
