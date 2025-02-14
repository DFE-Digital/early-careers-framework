# frozen_string_literal: true

# We time travel a lot in our feature tests which results
# in failures if the session expires.
expire_after = Rails.env.test? ? nil : 2.weeks
Rails.application.config.session_store :active_record_store, key: "_ecf_session", expire_after:
