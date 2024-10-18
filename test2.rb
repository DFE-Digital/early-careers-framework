Dir.glob(Rails.root.join("db/new_seeds/scenarios/**/*.rb")).each do |scenario|
  require scenario
end
include ActiveSupport::Testing::TimeHelpers

# LeadProvider.where(name: "Ambition Institute").each do |lead_provider|
LeadProvider.each do |lead_provider|
  10.times do
    NewSeeds::Scenarios::Participants::Transfers::FipToFipKeepingOriginalTrainingProvider
      .new(lead_provider_from: lead_provider)
      .build
    NewSeeds::Scenarios::Participants::Transfers::FipToFipChangingTrainingProvider
      .new(lead_provider_from: lead_provider)
      .build

    travel_to 1.year.from_now do
      NewSeeds::Scenarios::Participants::Transfers::FipToFipKeepingOriginalTrainingProvider
        .new(lead_provider_from: lead_provider)
        .build
      NewSeeds::Scenarios::Participants::Transfers::FipToFipChangingTrainingProvider
        .new(lead_provider_from: lead_provider)
        .build
    end
  end
end

##
# - participants result
# - "particiapnt status", value
