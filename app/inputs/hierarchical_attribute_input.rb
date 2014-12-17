class HierarchicalAttributeInput < SimpleForm::Inputs::CollectionInput
  include HierarchicalAttributesHelper

  def input(wrapper_options)
    @rendered_first_element = false
    input_html_classes.unshift("string")
    input_html_options[:class] << 'multi_value'
    input_html_options[:name] ||= "#{object_name}[#{attribute_name}][]"
    subfields = input_html_options[:subfields] ? input_html_options.delete(:subfields) : {}
    repeatable = input_html_options[:repeatable] ? input_html_options.delete(:repeatable) : ''

    populated_field_groups = ""
    collection.each_with_index do |entry,i|
      unless entry.to_s.strip.blank?
        populated_field_groups << <<-HTML
          <li class="field-wrapper hierarchical">
            #{build_subfields(subfields, entry, i)}
          </li>
        HTML
      end
    end

    if repeatable == 'false' && !populated_field_groups.blank?
      empty_field_group = ''
    else
      empty_field_group = <<-HTML
        <li class="field-wrapper hierarchical">
          #{build_subfields(subfields, nil, nil)}
        </li>
      HTML
    end

    markup = <<-HTML
      <ul class="listing hierarchical">
        #{populated_field_groups}
        #{empty_field_group}
      </ul>
    HTML

    return markup

  end

  private

  def build_subfields(subfields, entry, index=nil)
    markup = ""
    subfields_for(object, attribute_name).each do |subfield_name|
      if entry.nil? || entry.empty?
        value = entry
      else
        value = entry.send(subfield_name).first
      end
      if ! subfields[subfield_name] || ! subfields[subfield_name][:skip]
        markup << build_form_group(subfields, value, subfield_name, index:index, label: subfield_label(attribute_name, subfield_name))
       end
    end
    markup
  end

  def build_form_group(subfields, value, attribute_name, options={})
    group_label = options.fetch(:label, false) ? options.fetch(:label) : attribute_name.to_s.humanize
    markup = <<-HTML
      <div class="form-group">
        <label class="col-sm-2 control-label">#{group_label}</label>
        <div class="col-sm-10">
    HTML
    if subfields[attribute_name]
      case subfields[attribute_name][:type]
        when 'select'
          markup << build_select(subfields[attribute_name][:options], value, attribute_name.to_s, options.fetch(:index))
        else
          markup << build_text_field(value, attribute_name.to_s, options.fetch(:index))
      end
    else
      markup << build_text_field(value, attribute_name.to_s, options.fetch(:index))
    end
    markup << <<-HTML
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
    options[:class] += ["#{input_dom_id(field_name, index)} #{input_dom_id(field_name, nil)} form-control text-field"]
    options[:'aria-labelledby'] = label_id(field_name, index)
    @rendered_first_element = true

    return @builder.text_field(attribute_name, options)
  end

  def build_select(select_options, value, field_name, index)
    options = input_html_options.dup
    options[:name] = "#{object_name}[#{attribute_name}][][#{field_name}]"
    if @rendered_first_element
      options[:id] = nil
      options[:required] = nil
    else
      options[:id] ||= input_dom_id(field_name, index)
    end
    options[:class] ||= []
    options[:class] += ["#{input_dom_id(field_name, index)} #{input_dom_id(field_name, nil)} form-control text-field"]
    options[:'aria-labelledby'] = label_id(field_name, index)
    @rendered_first_element = true

    return @builder.select(attribute_name, select_options, {:selected => value}, options)
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
