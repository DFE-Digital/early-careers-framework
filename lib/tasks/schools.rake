# frozen_string_literal: true

namespace :schools do
  desc "Send nomination invitations to schools"
  task send_invites: :environment do
    InviteSchool.run(ARGV[1..-1])
  end
end
