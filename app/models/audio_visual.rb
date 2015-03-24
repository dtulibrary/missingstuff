# Generated via
#  `rails generate worthwhile:work AudioVisual`
class AudioVisual < ActiveFedora::Base
  include DtuCurationConcern
  has_attributes :audio_visual, datastream: :descMetadata, multiple: true
end
