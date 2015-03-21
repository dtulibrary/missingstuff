# Generated via
#  `rails generate worthwhile:work LectureNotes`
class LectureNote < ActiveFedora::Base
  include DtuCurationConcern

  # Single-value fields
  has_attributes :book, datastream: :descMetadata, multiple: true
end
