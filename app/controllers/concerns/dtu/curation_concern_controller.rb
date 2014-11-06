module Dtu
  # DTU-specific implementation of CurationConcernController behaviors
  # Primarily relies on behaviors mixed in from Worthwhile::CurationConcernController
  module CurationConcernController
    extend ActiveSupport::Concern
    include Worthwhile::CurationConcernController

    # Overrides verify_acceptance_of_user_agreement! method to always return true
    # This works around the fact that this check is hard-coded into the create method of Worthwhile::CurationConernController
    def verify_acceptance_of_user_agreement!
      return true
    end

  end
end