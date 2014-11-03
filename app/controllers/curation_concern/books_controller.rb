# Generated via
#  `rails generate worthwhile:work Book`

class CurationConcern::BooksController < ApplicationController
  include Worthwhile::CurationConcernController
  set_curation_concern_type Book
end
