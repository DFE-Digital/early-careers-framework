# frozen_string_literal: true

# Taken from https://github.com/rails/rails/blob/main/guides/source/autoloading_and_reloading_constants.md
# Makes ParticipantProfile::ECF behave properly in dev and test
# unless Rails.application.config.eager_load
#   Rails.autoloaders.main.on_load("ParticipantProfile") do
#     ParticipantProfile.connection.select_values(<<~SQL).each(&:constantize)
#       SELECT DISTINCT("#{ParticipantProfile.inheritance_column}")
#       FROM "#{ParticipantProfile.table_name}"
#       WHERE "#{ParticipantProfile.inheritance_column}" IS NOT NULL
#     SQL
#   end
# end
