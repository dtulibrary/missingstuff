# Generated via
#  `rails generate worthwhile:work ComputerProgram`
class ComputerProgram < ActiveFedora::Base
  include DtuCurationConcern

  # Single-value fields
  # Multi-value fields
  has_attributes :computer_program, datastream: :descMetadata, multiple: true
end
