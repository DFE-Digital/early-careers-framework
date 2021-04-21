# frozen_string_literal: true

in_local_environment = Rails.env.development? || Rails.env.test?

Rails.application.config.session_store :cookie_store, key: "_early_career_framework_session", secure: !in_local_environment, expire_after: 2.weeks
