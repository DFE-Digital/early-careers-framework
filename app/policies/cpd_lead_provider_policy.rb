class CpdLeadProviderPolicy < AdminProfilePolicy

  def update?
    user.admin?
  end
end
