module WithMxdMetadata
  extend ActiveSupport::Concern

  included do
    has_metadata "descMetadata", type: ::MxdDatastream
    validates_presence_of :title,  message: 'Your work must have a title.'

    # Single-value fields
    has_attributes :publication_date, :description, datastream: :descMetadata, multiple: false

    # Multi-value fields
    has_attributes :title, :person, datastream: :descMetadata, multiple: true
  end

  # Attributes that require special handling on updates
  def self.special_attributes
    [:person]
  end

  # Overrides attributes=
  # Intercepts all special_attributes, pulls their corresponding values out of the attributes hash, and calls the corresponding "update_*" method.
  # For example, if you declare a special_attribute of :person, all :person values will be passed to the update_people method
  # If update_people is not defined, the :person values will be ignored.
  # All regular attributes are handled with default update_attributes behavior.
  def attributes=(attributes)
    filtered_attributes = attributes.dup
    WithMxdMetadata.special_attributes.each do |attribute|
      subs = subfields_for(attribute)
      values = filtered_attributes.delete(attribute)
      unless values.nil?
        self.send("#{attribute}=".to_sym, nil)
        values.each_with_index do |field, index|
          unless subfields_empty?(field, subs)
            subs.each do |sub|
              self.send(attribute,index).send("#{sub}=".to_sym,field.fetch(sub))
            end
          end
        end
      end
    end
    super(filtered_attributes)
  end

  # Lists the term names for the subfields of the attribute identified by attribute_name
  # Assumes that the term is defined on the descMetadata datastream
  # @example
  #   subfields_for(:person)
  #   => [:first_name, :last_name, :role]
  def subfields_for(attribute_name)
    begin
      term = descMetadata.send(attribute_name).term
    end
    if term
      return term.children.keys
    else
      nil
    end
  end

  def subfields_empty?(new_values, subs)
    subs.each do |sub|
      value = new_values.fetch(sub)
      return false unless value.nil? || value.empty?
    end
    return true
  end
end
