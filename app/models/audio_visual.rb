# Generated via
#  `rails generate worthwhile:work AudioVisual`
class AudioVisual < ActiveFedora::Base
  include ::CurationConcern::Work
  include ::CurationConcern::WithBasicMetadata
  validates_presence_of :title,  message: 'Your work must have a title.'
end
