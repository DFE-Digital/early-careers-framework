# frozen_string_literal: true

module ValidTestDataGenerators
  class SeparationSharedData < ECFLeadProviderPopulater
    class << self
      def call(name:, cohort:)
        new(name:, cohort:)
      end
    end

    def call
      school = lead_provider.schools.sample
      sparsity_uplift = weighted_choice(selection: [true, false], odds: [11, 89])
      pupil_premium_uplift = weighted_choice(selection: [true, false], odds: [11, 39])

      status = weighted_choice(selection: %w[active withdrawn], odds: [6, 1])
      profile_type = weighted_choice(selection: %i[mentor ect], odds: [9, 1])
      school_cohort = school_cohort(school:)

      (shared_users_data[lead_provider.name] || []).each do |user_params|
        participant_identity = shared_participant_identity(user_params)

        participant = create_participant(
          participant_identity:,
          school_cohort:,
          profile_type:,
          status:,
          sparsity_uplift:,
          pupil_premium_uplift:,
        )

        next unless profile_type == :mentor

        rand(0..3).times do
          create_participant(
            participant_identity: create_random_participant_identity,
            school_cohort:,
            profile_type: :ect,
            mentor_profile: participant,
            status:,
            sparsity_uplift:,
            pupil_premium_uplift:,
          )
        end
      end
    end

    def shared_participant_identity(params)
      user = if params[:ecf_id].present?
               User.find_or_initialize_by(id: params[:ecf_id])
             else
               User.find_or_initialize_by(email: params[:email])
             end
      user.update!(full_name: params[:name], email: params[:email])

      teacher_profile = TeacherProfile.find_or_initialize_by(user:)
      teacher_profile.update!(trn: params[:trn])

      Identity::Create.call(user:, origin: :ecf)
    end

    def shared_users_data
      @shared_users_data ||= YAML.load_file(Rails.root.join("db/data/separation_shared_data.yml"))
    end
  end
end
