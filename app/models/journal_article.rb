# Generated via
#  `rails generate worthwhile:work JournalArticle`
class JournalArticle < ActiveFedora::Base
  include DtuCurationConcern
  validates_presence_of :title,  message: 'Your work must have a title.'
end
