# This catches the fields that are used by default in Worthwhile
# as we express those fields in MXD or remove the fields from Create/Edit forms, we can remove them from here
# and eventually remove the WithWorthwhiledMetadata module (and corresponding datastream) entirely.
module WithWorthwhileMetadata
  extend ActiveSupport::Concern

  included do
    has_metadata "miscMetadata", type: ::GenericWorkMetadata

    # Single-value fields
    has_attributes :created, :date_modified, :date_uploaded, datastream: :miscMetadata, multiple: false

    # Multi-value fields
    has_attributes :contributor, :creator, :coverage, :date, :description, :content_format, :identifier,
                   :language, :publisher, :relation, :rights, :source, :subject, :type,
                   datastream: :miscMetadata, multiple: true
  end
end