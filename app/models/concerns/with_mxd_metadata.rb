module WithMxdMetadata
  extend ActiveSupport::Concern

  included do
    has_metadata "descMetadata", type: ::MxdDatastream
    validates_presence_of :title,  message: 'Your work must have a title.'

    # Single-value fields
    # Note: :created, :date_modified, :date_uploaded are required by Worthwhile.  If you don't want them in the MXD, move them to another datastream.
    has_attributes :created, :date_modified, :date_uploaded, :description, :title, :publication_date, datastream: :descMetadata, multiple: false

    # Multi-value fields
    has_attributes :person, datastream: :descMetadata, multiple: true
  end

  # Attributes that require special handling on updates
  def special_attributes
    [:person]
  end

  def update_people(persons_array)
    self.person = nil unless persons_array.nil?
    persons_array.each_with_index do |person, index|
      self.person(index).first_name = person.fetch(:first_name)
      self.person(index).last_name = person.fetch(:last_name)
      self.person(index).role = person.fetch(:role)
    end
  end

  # Overrides attributes=
  # Intercepts all special_attributes, pulls their corresponding values out of the attributes hash, and calls the corresponding "update_*" method.
  # For example, if you declare a special_attribute of :person, all :person values will be passed to the update_people method
  # If update_people is not defined, the :person values will be ignored.
  # All regular attributes are handled with default update_attributes behavior.
  def attributes=(attributes)
    filtered_attributes = attributes.dup
    special_attributes.each do |attribute|
      values = filtered_attributes.delete(attribute)
      method_name = "update_#{attribute.to_s.pluralize}".to_sym
      if respond_to?(method_name)
        self.send(method_name, values) unless values.nil?
      end
    end
    super(filtered_attributes)
  end
end
