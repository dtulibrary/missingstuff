class HierarchicalAttributeInput < SimpleForm::Inputs::CollectionInput
  include HierarchicalAttributesHelper

  def input(wrapper_options)
    puts "###"
    puts @builder
    puts @attribute_name
    puts @column
    puts @input_type
    puts "###"
    @rendered_first_element = false
    input_html_classes.unshift("string")
    input_html_options[:class] << 'multi_value'
    input_html_options[:name] ||= "#{object_name}[#{attribute_name}][]"

    populated_field_groups = ""
    collection.each_with_index do |entry,i|
      unless entry.to_s.strip.blank?
        populated_field_groups << <<-HTML
          <li class="field-wrapper">
            #{build_subfields(entry, i)}
          </li>
        HTML
      end
    end

    empty_field_group = <<-HTML
      <li class="field-wrapper">
        #{build_subfields(nil, nil)}
      </li>
    HTML

    markup = <<-HTML
      <ul class="listing hierarchical">
        #{populated_field_groups}
        #{empty_field_group}
      </ul>
    HTML

    return markup

  end

  private

  def build_subfields(entry, index=nil)
    markup = ""
    subfields_for(object, attribute_name).each do |subfield_name|
      if entry.nil? || entry.empty?
        value = entry
      else
        value = entry.send(subfield_name).first
      end
      markup << build_form_group(value, subfield_name, index)
    end
    markup
  end

  def build_form_group(value, attribute_name, index=nil)
    markup = <<-HTML
      <div class="form-group">
        <label class="col-sm-4 control-label">#{attribute_name.to_s.humanize}</label>
        <div class="col-sm-8">
          #{build_text_field(value, attribute_name.to_s, index)}
        </div>
      </div>
    HTML
    markup
  end

  def build_text_field(value, field_name, index)
    options = input_html_options.dup
    options[:name] = "#{object_name}[#{attribute_name}][][#{field_name}]"
    options[:value] = value
    if @rendered_first_element
      options[:id] = nil
      options[:required] = nil
    else
      options[:id] ||= input_dom_id(field_name, index)
    end
    options[:class] ||= []
    options[:class] += ["#{input_dom_id(field_name, index)} form-control text-field"]
    options[:'aria-labelledby'] = label_id(field_name, index)
    @rendered_first_element = true

    return @builder.text_field(attribute_name, options)
  end


  def label_id(field_name = nil, index=nil)
    input_dom_id(field_name, index) + '_label'
  end

  def input_dom_id(field_name = nil, index=nil)
    base_id = input_html_options[:id] || "#{object_name}_#{attribute_name}"
    to_concatenate = [base_id]
    to_concatenate << index unless index.nil?
    to_concatenate << field_name unless field_name.nil?
    return to_concatenate.join("_")
  end

  def collection
    @collection ||= hierarchical_attribute_collection(object, attribute_name)
  end

  def multiple?; true; end
end
