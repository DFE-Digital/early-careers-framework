# frozen_string_literal: true

module DeliveryPartners
  class ParticipantsFilter
    attr_reader :collection, :params, :training_record_states

    def initialize(collection:, params:, training_record_states:)
      @collection = collection
      @params = params
      @training_record_states = training_record_states
    end

    def scope
      scoped = collection

      if params[:query].present?
        scoped = filter_query(scoped, params[:query])
      end

      if params[:role].present?
        scoped = filter_role(scoped, params[:role])
      end

      if params[:academic_year].present?
        scoped = filter_academic_year(scoped, params[:academic_year])
      end

      if params[:status].present?
        scoped = filter_status(scoped, params[:status])
      end

      scoped
    end

    def filter_query(scoped, query)
      fields = %w[
        user_full_name
        user_email
        user_teacher_profile_trn
        induction_programme_partnership_lead_provider_name
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

    def filter_role(scoped, role)
      case role
      when "ect"
        scoped.where(participant_profile: { type: "ParticipantProfile::ECT" })
      when "mentor"
        scoped.where(participant_profile: { type: "ParticipantProfile::Mentor" })
      else
        scoped
      end
    end

    def filter_academic_year(scoped, academic_year)
      scoped.includes(
        :cohort,
      ).where(cohort: { start_year: academic_year })
    end

    def filter_status(scoped, status)
      ids = []

      scoped.each do |induction_record|
        status_tag = StatusTags::DeliveryPartnerParticipantStatusTag.new(training_record_states[induction_record.participant_profile_id])

        if status_tag.id == status
          ids << induction_record.id
        end
      end

      scoped.where(id: ids)
    end

    def role_options
      [
        OpenStruct.new(id: "", name: ""),
        OpenStruct.new(id: "ect", name: "Early career teacher"),
        OpenStruct.new(id: "mentor", name: "Mentor"),
      ]
    end

    def academic_year_options
      [OpenStruct.new(id: "", name: "")] +
        Cohort.order(:start_year).map do |c|
          OpenStruct.new(id: c.start_year, name: c.start_year)
        end
    end

    def status_options
      [OpenStruct.new(id: "", name: "")] +
        I18n.t("status_tags.delivery_partner_participant_status").map { |_k, v| OpenStruct.new(id: v[:id], name: v[:label]) }.uniq
    end
  end
end
