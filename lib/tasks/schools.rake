# frozen_string_literal: true

namespace :schools do
  desc "Send nomination invitations to schools"
  task :send_invites, [:school_urns] => :environment do |_task, args|
    InviteSchools.new.run(args.school_urns.split)
  end
end
