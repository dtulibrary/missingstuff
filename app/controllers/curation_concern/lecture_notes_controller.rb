# Generated via
#  `rails generate worthwhile:work LectureNotes`

class CurationConcern::LectureNotesController < ApplicationController
  include Dtu::CurationConcernController
  set_curation_concern_type LectureNote
end
