# frozen_string_literal: true

require "rake"

namespace :support do
  namespace :sit do
    desc "Replace the SIT for a school"
    task :replace, %i[school_id full_name email] => :environment do |_task, args|
      school_id = args.school_id
      full_name = args.full_name
      email = args.email

      Support::SchoolInductionTutors::Replace.new(school_id: school_id, full_name: full_name, email: email).call
    end

    desc "Update the Name and Email for a school's existing SIT"
    task :update, %i[school_id full_name email] => :environment do |_task, args|
      school_id = args.school_id
      full_name = args.full_name
      email = args.email

      Support::SchoolInductionTutors::Update.new(school_id: school_id, full_name: full_name, email: email).call
    end
  end
end
