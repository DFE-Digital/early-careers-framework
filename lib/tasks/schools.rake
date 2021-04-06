# frozen_string_literal: true

namespace :schools do
  desc "Send nomination invitations to schools"
  task :send_invites, [:school_ids] => :environment do |task, args|
    InviteSchools.new.run(args.school_ids.split)
  end
end
