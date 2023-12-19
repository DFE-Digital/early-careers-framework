class PopulateIttProviderIdInApplications < ActiveRecord::Migration[7.0]
  def up
    # Use SQL to update the school_id column based on school_urn
    execute <<-SQL
      UPDATE applications
      SET itt_provider_id = itt_providers.id
      FROM itt_providers
      WHERE applications.itt_provider = itt_providers.legal_name
    SQL
  end

  def down; end
end
