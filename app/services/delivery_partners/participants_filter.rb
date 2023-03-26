# frozen_string_literal: true

module DeliveryPartners
  class ParticipantsFilter
    attr_reader :collection, :params

    def initialize(collection:, params:)
      @collection = collection
      @params = params
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
        induction_records_induction_programme_partnership_lead_provider_name
        induction_records_school_cohort_school_name
        induction_records_school_cohort_school_urn
      ].join("_or_")

      scoped.includes(
        user: [
          :teacher_profile,
        ],
        induction_records: {
          induction_programme: { partnership: [:lead_provider] },
        },
      ).ransack("#{fields}_cont": query).result.distinct
    end

    def filter_role(scoped, role)
      case role
      when "ect"
        scoped.where(type: "ParticipantProfile::ECT")
      when "mentor"
        scoped.where(type: "ParticipantProfile::Mentor")
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
      scoped.each do |pp|
        ir = pp.relevant_induction_record_for(delivery_partner: params[:delivery_partner])

        pps = ParticipantProfileStatus.new(participant_profile: pp, induction_record: ir)
        if pps.is_status?(status)
          ids << pp.id
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
        %w[
          contacted_for_information
          dfe_checking_eligibility
          checking_qts
          training_or_eligible_for_training
          no_longer_being_trained
          not_eligible_for_funded_training
        ]
          .index_with { |record_state| I18n.t(:label, scope: "status_tags.appropriate_body_participant_status.#{record_state}") }
          .map { |c| OpenStruct.new(id: c[0], name: c[1]) }
    end
  end
end
