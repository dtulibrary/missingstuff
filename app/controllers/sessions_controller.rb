class SessionsController < DtuSessionsController
  def find_local_user_by_provider_and_identifier provider, identifier
    User.find_by_provider_and_identifier provider, identifier
  end

  def create_or_update_local_user provider, user_data
    User.create_or_update provider, user_data
  end
end
