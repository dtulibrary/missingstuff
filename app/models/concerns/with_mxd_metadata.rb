module WithMxdMetadata
  extend ActiveSupport::Concern

  included do
    has_metadata "descMetadata", type: ::MxdDatastream
    validates_presence_of :title,  message: 'Your work must have a title.'

    # Single-value fields
    has_attributes :lang, :title, :description, :publication_date, datastream: :descMetadata, multiple: false

    # Multi-value fields
    has_attributes :subtitle, :keyword, :person, :editor, :details, :series, :organisation, :requester, datastream: :descMetadata, multiple: true
  end

  # Attributes that require special handling on updates
  def self.special_attributes
    [:person, :editor, :organisation, :event, :book, :details, :series, :computer_program, :audio_visual]
  end

  # Overrides attributes=
  # Intercepts all special_attributes, pulls their corresponding values out of the attributes hash, and calls the corresponding "update_*" method.
  # For example, if you declare a special_attribute of :person, all :person values will be passed to the update_people method
  # If update_people is not defined, the :person values will be ignored.
  # All regular attributes are handled with default update_attributes behavior.
  def attributes=(attributes)
    if descMetadata.class == MxdDatastream
      filtered_attributes = attributes.dup
      WithMxdMetadata.special_attributes.each do |attribute|
        subs = subfields_for(attribute)
        values = filtered_attributes.delete(attribute)
        unless values.nil?
          self.send("#{attribute}=".to_sym, nil)
          values.each_with_index do |field, index|
            unless subfields_empty?(field, subs)
              subs.each do |sub|
                if field.key? sub
                  self.send(attribute,index).send("#{sub}=".to_sym,field.fetch(sub))
                end
              end
            end
          end
        end
      end
      super(filtered_attributes)
    else
      super(attributes)
    end
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
      if new_values.key? sub
        value = new_values.fetch(sub)
        return false unless value.nil? || value.empty?
      end
    end
    return true
  end

  def authority_options(authority, type)
    case authority
      when 'person_role'
        Rails.logger.info "person_role - type: #{type}"
        case type.to_s
          when 'ComputerProgram'
            Rails.logger.info "person_role - ComputerProgram"
            [['',''],['Author','pau'],['Developer','pdev'],['Editor','ped'],['Illustrator', 'pil'],['Invited author','paui'],['Publisher','ppu'],
             ['Supervisor','sup'],['Translator','ptr'],['Other','poth']]
          when 'AudioVisual'
            Rails.logger.info "person_role - AudioVisual"
            [['',''],['Author','pau'],['Composer','pcom'],['Editor','ped'],['Illustrator', 'pil'],['Invited author','paui'],['Performer','pper'],
             ['Photographer','ppho'],['Publisher','ppu'],['Supervisor','sup'],['Translator','ptr'],['Other','poth']]
          else
            Rails.logger.info "person_role - other"
            [['',''],['Author','pau'],['Editor','ped'],['Illustrator', 'pil'],['Invited author','paui'],['Publisher','ppu'],
             ['Supervisor','sup'],['Translator','ptr'],['Other','poth']]
        end
    end
  end

  def display_type(type=nil)
     if type
       name = type.to_s
     else
       name = self.class.to_s
     end
     case name
      when 'Other'
         "Other Contribution"
      else
        self.class.to_s.demodulize.titleize
    end
  end
  
end
