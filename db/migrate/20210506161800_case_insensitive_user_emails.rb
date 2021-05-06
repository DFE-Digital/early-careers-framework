# frozen_string_literal: true

class CaseInsensitiveUserEmails < ActiveRecord::Migration[6.1]
  def up
    enable_extension("citext")

    change_column :users, :email, :citext, null: false
  end

  def down
    change_column :users, :email, :string, null: false, default: ""

    # GovUK PaaS has "citext" extension enabled by default which cannot be disabled.
    # See: https://docs.cloud.service.gov.uk/deploying_services/postgresql/#force-a-failover
    # disable_extension("citext")
  end
end
