# frozen_string_literal: true

namespace :compare do
  namespace :event_history_analyser do
    desc "Extracts a history of events from each user in the database"

    task :run, %i[batch_size page] => :environment do |_task, args|
      args.with_defaults batch_size: "1000", page: "1"

      report_batch_size = args[:batch_size].to_i
      report_page = args[:page].to_i - 1
      report_page = 0 if report_page.negative?

      folder_timestamp = Time.zone.now.strftime "%Y-%m-%d"
      folder_path = "/tmp/#{folder_timestamp}"
      unless Dir.exist? folder_path
        puts "[#{Time.current.strftime('%H:%M:%S')}] Creating folder #{folder_path}/"
        Dir.mkdir folder_path
      end

      ecf_participant_profiles = ParticipantProfile::ECF.order(:created_at)
                                        .limit(report_batch_size)
                                        .offset(report_page * report_batch_size)

      events = []
      ecf_participant_profiles.each do |participant_profile|
        Participants::HistoryBuilder.from_participant_profile(participant_profile).events.each { |event| events << event.to_h }
      end

      file_path = "#{folder_path}/event-history-#{args[:page]}.json"
      puts "[#{Time.current.strftime('%H:%M:%S')}] Writing #{events.count} events to #{file_path}"
      File.open(file_path, "w") { |r| r.puts JSON.generate(events) }
    end
  end
end
