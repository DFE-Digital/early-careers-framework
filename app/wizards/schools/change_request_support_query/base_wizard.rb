# frozen_string_literal: true

module Schools
  module ChangeRequestSupportQuery
    class BaseWizard < DfE::Wizard::Base
      attr_accessor :change_request_type, :current_user, :school_id, :start_year, :participant_id, :store

      steps do
        [
          {
            start: StartStep,
            contact_providers: ContactProvidersStep,
            email: EmailStep,
            relation: RelationStep,
            check_your_answers: CheckYourAnswersStep,
            success: SuccessStep,
          },
        ]
      end

      def default_path_arguments
        { change_request_type:, school_id:, participant_id:, start_year: }
      end

      def save!
        current_step.save! if current_step.respond_to?(:save!)

        if complete?
          create_support_query!
          store.destroy # rubocop:disable Rails/SaveBang
        end
      end

      def create_support_query!
        CreateChangeRequestSupportQuery.call(
          current_user:,
          participant:,
          school:,
          academic_year:,
          current_relation:,
          new_relation:,
        )
      end

      def current_relation
        @current_relation ||= if relation_klass == LeadProvider
                                school.lead_provider(start_year)
                              else
                                school.delivery_partner_for(start_year)
                              end
      end

      def new_relation
        @new_relation ||= relation_klass.find(store.attrs_for(:relation)[:relation_id])
      end

      def available_relations
        relations - [current_relation]
      end

      def relations
        if relation_klass == DeliveryPartner
          school.lead_provider(start_year).delivery_partners.order(:name)
        else
          LeadProvider.all.order(:name)
        end
      end

      def school
        @school ||= School.find(school_id)
      end

      def participant
        return unless participant_change_request?

        @participant ||= ParticipantProfile.find(participant_id)
      end

      def preferred_email
        store.attrs_for(:email)[:email].presence || participant.user.email
      end

      def complete?
        store.attrs_for(:check_your_answers)&.fetch(:complete, nil) == "true"
      end

      def participant_change_request?
        participant_id.present?
      end

      def relation_klass
        change_request_type == "change-lead-provider" ? LeadProvider : DeliveryPartner
      end

      def academic_year
        @academic_year ||= "#{start_year} to #{start_year.to_i + 1}"
      end
    end
  end
end
