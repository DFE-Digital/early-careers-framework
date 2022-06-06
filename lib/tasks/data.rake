# frozen_string_literal: true

namespace :data do
  namespace :privacy_policy do
    desc "Stores the content of data/privacy_policy.html file as the next minor privacy policy version"
    task minor: :environment do
      PrivacyPolicy::Publish.call(
        major: false,
        logger: Logger.new($stdout, formatter: ->(_level, _time, _data, msg) { "#{msg}\n" }),
      )
    end

    desc "Stores the content of data/privacy_policy.html file as the next major privacy policy version"
    task major: :environment do
      PrivacyPolicy::Publish.call(
        major: true,
        logger: Logger.new($stdout, formatter: ->(_level, _time, _data, msg) { "#{msg}\n" }),
      )
    end
  end

  namespace :historical_states do
    desc "Updates the participant declaration with missing submitted states"
    task populate: :environment do
      DeclarationState.where(state: "eligible").all.each do |declaration_state|
        participant_declaration = declaration_state.participant_declaration
        unless participant_declaration.nil? || participant_declaration.declaration_states.any?(state: "submitted")
          DeclarationState.create!(participant_declaration:, state: "submitted", created_at: participant_declaration.created_at)
        end
      end
    end
  end
end
