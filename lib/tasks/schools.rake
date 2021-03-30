# frozen_string_literal: true

namespace :schools do
  desc "Send nomination invitations to schools"
  task send_invites: :environment do
    InviteSchools.new.run(ARGV[1..-1])
  end
end
