# Generated via
#  `rails generate worthwhile:work Other`
class Other < ActiveFedora::Base
  include ::CurationConcern::Work
  include ::CurationConcern::WithBasicMetadata
  validates_presence_of :title,  message: 'Your work must have a title.'
end
