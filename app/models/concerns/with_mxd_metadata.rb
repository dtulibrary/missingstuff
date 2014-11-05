module WithMxdMetadata
  extend ActiveSupport::Concern

  included do
    has_metadata "descMetadata", type: ::MxdDatastream
    validates_presence_of :title,  message: 'Your work must have a title.'

    # Single-value fields
    has_attributes :publication_date, datastream: :descMetadata, multiple: false

    # Multi-value fields
    has_attributes :title, :description, :person, datastream: :descMetadata, multiple: true
  end

  # Attributes that require special handling on updates
  def special_attributes
    {:person => [:first_name, :last_name, :role]}
  end

  # Overrides attributes=
  # Intercepts all special_attributes, pulls their corresponding values out of the attributes hash, and calls the corresponding "update_*" method.
  # For example, if you declare a special_attribute of :person, all :person values will be passed to the update_people method
  # If update_people is not defined, the :person values will be ignored.
  # All regular attributes are handled with default update_attributes behavior.
  def attributes=(attributes)
    filtered_attributes = attributes.dup
    special_attributes.each_pair do |attribute,subs|
      values = filtered_attributes.delete(attribute)
      unless values.nil?
        self.send("#{attribute}=".to_sym, nil)
        values.each_with_index do |field, index|
          subs.each do |sub|
            self.send(attribute,index).send("#{sub}=".to_sym,field.fetch(sub))
          end
        end
      end
    end
    super(filtered_attributes)
  end
end
