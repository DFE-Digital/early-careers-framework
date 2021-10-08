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

  namespace :profile_declarations do
    desc "Copies the profile to the declarations from the deprecated profile_declarations table"
    task copy: :environment do
      ProfileDeclaration.in_batches(of: 1000) do |batch|
        batch.each do |declaration|
          declaration.participant_declaration.update(participant_profile_id: declaration.participant_profile_id)
        end
      end
    end
  end
end
