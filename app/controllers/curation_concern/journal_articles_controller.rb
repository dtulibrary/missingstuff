# Generated via
#  `rails generate worthwhile:work JournalArticle`

class CurationConcern::JournalArticlesController < ApplicationController
  include Worthwhile::CurationConcernController
  set_curation_concern_type JournalArticle
end
