# Generated via
#  `rails generate worthwhile:work LectureNotes`
class LectureNote < ActiveFedora::Base
  include ::CurationConcern::Work
  include ::WithMxdMetadata
end
