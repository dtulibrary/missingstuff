# Generated via
#  `rails generate worthwhile:work LectureNotes`
class LectureNote < ActiveFedora::Base
  include DtuCurationConcern

  # Single-value fields
  has_attributes :event, datastream: :descMetadata, multiple: false
end
