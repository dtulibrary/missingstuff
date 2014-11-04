Worthwhile.configure do |config|
  # Injected via `rails g worthwhile:work LectureNotes`
  config.register_curation_concern :lecture_note
  # Injected via `rails g worthwhile:work Book`
  config.register_curation_concern :book
end


