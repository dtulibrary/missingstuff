Worthwhile.configure do |config|
  # Injected via `rails g worthwhile:work Book`
  config.register_curation_concern :book
  # Injected via `rails g worthwhile:work BookChapter`
  config.register_curation_concern :book_chapter
  # Injected via `rails g worthwhile:work JournalArticle`
  config.register_curation_concern :journal_article
  # Injected via `rails g worthwhile:work LectureNotes`
  config.register_curation_concern :lecture_note
  # Injected via `rails g worthwhile:work Report`
  config.register_curation_concern :report
  # Injected via `rails g worthwhile:work ReportChapter`
  config.register_curation_concern :report_chapter
end


