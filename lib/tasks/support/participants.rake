# frozen_string_literal: true

require "rake"

namespace :support do
  namespace :participants do
    namespace :reactivate do
      desc "Reactivates a participant, moving their training and induction statuses to active"
      task :run, %i[participant_profile_id] => :environment do |_task, args|
        participant_profile_id = args.participant_profile_id

        Support::Participants::Reactivate.call(participant_profile_id:)
      end

      desc "DRY RUN (rolls back on completion): Reactivates a participant, moving their training and induction statuses to active"
      task :dry_run, %i[participant_profile_id] => :environment do |_task, args|
        participant_profile_id = args.participant_profile_id

        Support::Participants::Reactivate.new(participant_profile_id:).dry_run
      end
    end

    namespace :mentors do
      namespace :remove do
        desc "Removes a participant from a school"
        task :run, %i[participant_profile_id school_urn] => :environment do |_task, args|
          participant_profile_id = args.participant_profile_id
          school_urn = args.school_urn

          Support::Participants::Mentors::Remove.call(participant_profile_id:, school_urn:)
        end

        desc "DRY RUN (rolls back on completion): Removes a participant from a school"
        task :dry_run, %i[participant_profile_id school_urn] => :environment do |_task, args|
          participant_profile_id = args.participant_profile_id
          school_urn = args.school_urn

          Support::Participants::Mentors::Remove.new(participant_profile_id:, school_urn:).dry_run
        end
      end
    end
  end
end
