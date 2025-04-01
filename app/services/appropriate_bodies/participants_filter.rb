# frozen_string_literal: true

module AppropriateBodies
  class ParticipantsFilter
    attr_reader :collection, :params, :training_record_states

    def initialize(collection:, params:, training_record_states:)
      @collection = collection
      @params = params
      @training_record_states = training_record_states
    end

    def scope
      scoped = collection.includes(
        :cohort,
      ).where(cohort: { start_year: Cohort.active_registration_cohort.start_year })

      if params[:query].present?
        scoped = filter_query(scoped, params[:query])
      end

      if params[:status].present?
        scoped = filter_status(scoped, params[:status])
      end

      scoped.order(updated_at: :desc)
    end

    def filter_query(scoped, query)
      fields = %w[
        user_full_name
        user_teacher_profile_trn
        school_cohort_school_name
        school_cohort_school_urn
      ].join("_or_")

      scoped.includes(
        user: [
          :teacher_profile,
        ],
        induction_programme: { partnership: [:lead_provider] },
      ).ransack("#{fields}_cont": query).result.distinct
    end

    def filter_status(scoped, status)
      ids = []
      scoped.each do |induction_record|
        status_tag = StatusTags::AppropriateBodyParticipantStatusTag.new(training_record_states[induction_record.participant_profile_id])

        if status_tag.id == status
          ids << induction_record.id
        end
      end

      scoped.where(id: ids)
    end

    def status_options
      [OpenStruct.new(id: "", name: "")] +
        I18n.t("status_tags.appropriate_body_participant_status").map { |_k, v| OpenStruct.new(id: v[:id], name: v[:label]) }.uniq
    end
  end
end
