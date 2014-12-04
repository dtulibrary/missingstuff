# Generated via
#  `rails generate worthwhile:work BookChapter`
class BookChapter < ActiveFedora::Base
  include DtuCurationConcern
  # Single-value fields
  # Multi-value fields
  has_attributes :book, datastream: :descMetadata, multiple: true
end
