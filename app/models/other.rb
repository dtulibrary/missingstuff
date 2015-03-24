# Generated via
#  `rails generate worthwhile:work Other`
class Other < ActiveFedora::Base
  include DtuCurationConcern

  has_attributes :other, datastream: :descMetadata, multiple: true
  has_attributes :book, datastream: :descMetadata, multiple: true
  def self.display_name(type=nil)
    "Other Contribution"
  end
end
