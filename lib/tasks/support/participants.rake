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
  end
end
