# Generated via
#  `rails generate worthwhile:work Book`
class Book < ActiveFedora::Base
  include ::CurationConcern::Work
  include ::WithMxdMetadata
end
