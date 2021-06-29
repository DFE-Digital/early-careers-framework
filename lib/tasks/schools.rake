# frozen_string_literal: true

namespace :schools do
  desc "Send nomination invitations to schools"
  task :send_invites, [:school_urns] => :environment do |_task, args|
    InviteSchools.new.run(args.school_urns.split)
  end

  desc "Send chaser nomination invites to schools without induction coordinators"
  task send_chasers: :environment do
    InviteSchools.new.send_chasers
  end

  desc "Send private beta invitations to schools"
  task :invite_to_beta, [:school_urns] => :environment do |_task, args|
    InviteSchools.new.invite_to_beta(args.school_urns.split)
  end

  desc "Resend private beta invitations to schools without participants"
  task send_beta_chasers: :environment do
    InviteSchools.new.send_beta_chasers
  end

  desc "Send nomination links to MAT schools"
  task :invite_mats, [:school_urns] => :environment do |_task, args|
    InviteSchools.new.invite_mats(args.school_urns.split)
  end

  desc "Send nomination links to federation schools"
  task :invite_federations, [:school_urns] => :environment do |_task, args|
    InviteSchools.new.invite_federations(args.school_urns.split)
  end

  desc "Send chasers to induction coordinators who have not signed in"
  task send_induction_coordinator_sign_in_chasers: :environment do
    InviteSchools.new.send_induction_coordinator_sign_in_chasers
  end
end
