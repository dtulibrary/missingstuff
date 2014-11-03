# Generated via
#  `rails generate worthwhile:work LectureNotes`
class LectureNotes < ActiveFedora::Base
  include ::CurationConcern::Work
  include ::CurationConcern::WithBasicMetadata
end
