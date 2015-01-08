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

    # Overrides attributes_for_actor to whitelist *all* attributes submitted for the curation concern
    # NOTE: For better security, override this on each controller to only allow the relevant attributes
    # ie. in BooksController, override the attributes_for_actor method with `params.require(:book).permit(:title, :description, :subject)`
    def attributes_for_actor
      params.require(hash_key_for_curation_concern).permit!
    end

  end
end