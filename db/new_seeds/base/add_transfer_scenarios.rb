# frozen_string_literal: true

seed_quantity(:fip_to_fip_transfers_keeping_original_provider).times do
  NewSeeds::Scenarios::Participants::Transfers::FipToFipKeepingOriginalTrainingProvider.new.build
end

seed_quantity(:fip_to_fip_transfers_changing_provider).times do
  NewSeeds::Scenarios::Participants::Transfers::FipToFipChangingTrainingProvider.new.build
end
