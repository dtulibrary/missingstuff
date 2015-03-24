# Generated via
#  `rails generate worthwhile:work Other`
class Other < ActiveFedora::Base
  include DtuCurationConcern

  def self.display_name(type=nil)
    "Other Contribution"
  end
end
