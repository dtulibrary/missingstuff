require 'dtu_rails_common/authentication'

module DtuRailsCommon
  module Authentication
    def new_session_path params
      "/login?#{params.to_query}"
    end
  end
end
