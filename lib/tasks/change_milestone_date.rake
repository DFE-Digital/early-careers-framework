# frozen_string_literal: true

require "rake"

namespace :change_milestone_date do
  desc "Validate if a milestone date can be changed"
  task :validate, %i[schedule_identifier start_year milestone_number new_start_date new_milestone_date] => :environment do |_task, args|
    args = args.to_h
    change = ChangeMilestoneDate.new(args)

    if change.valid?
      puts "Milestone date can be changed to #{args.slice(:new_start_date, :new_milestone_date)}"
      puts "#{change.milestone_declarations.count} declarations will remain valid after the change"
      puts "Milestone details: #{change.milestone.attributes}"
    else
      puts change.errors.full_messages
    end
  end

  desc "Executes a milestone date change (if valid)"
  task :execute, %i[schedule_identifier start_year milestone_number new_start_date new_milestone_date] => :environment do |_task, args|
    ChangeMilestoneDate.new(args.to_h).change_date!
  end
end
