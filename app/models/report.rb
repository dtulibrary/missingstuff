# Generated via
#  `rails generate worthwhile:work Report`
class Report < ActiveFedora::Base
  include DtuCurationConcern
  validates_presence_of :title,  message: 'Your work must have a title.'
  has_attributes :book, datastream: :descMetadata, multiple: true
end
