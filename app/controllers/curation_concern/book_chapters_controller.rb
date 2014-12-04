# Generated via
#  `rails generate worthwhile:work BookChapter`

class CurationConcern::BookChaptersController < ApplicationController
  include Dtu::CurationConcernController
  set_curation_concern_type BookChapter
end
