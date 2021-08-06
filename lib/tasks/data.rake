# frozen_string_literal: true

namespace :data do
  namespace :privacy_policy do
    desc "Stores the content of data/privacy_policy.html file as the next minor privacy policy version"
    task minor: :environment do
      PrivacyPolicy::Publish.call(
        major: false,
        logger: Logger.new(STDOUT, formatter: ->(_level, _time, _data, msg) { "#{msg}\n" }),
      )
    end

    desc "Stores the content of data/privacy_policy.html file as the next major privacy policy version"
    task major: :environment do
      PrivacyPolicy::Publish.call(
        major: true,
        logger: Logger.new(STDOUT, formatter: ->(_level, _time, _data, msg) { "#{msg}\n" }),
      )
    end
  end
end
