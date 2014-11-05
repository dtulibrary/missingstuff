class PersonInput < SimpleForm::Inputs::CollectionInput
  include HierarchicalFieldsHelper

  #
  #<div class="form-group person optional book_person">
  #  <label class="person optional control-label" for="book_person">Person</label>
  #  <div>
  #    <ul class="listing">
  #      <li class="field-wrapper">
  #        <label class="person_first_name optional control-label" for="book_person_first_name">First Name</label>
  #        <input aria-labelledby="book_person_first_name_label" class="string person_first_name optional book_person_first_name form-control multi-text-field" id="book_person_first_name" name="book[person][][first_name]" type="text" value="">
  #        <label class="person_last_name optional control-label" for="book_person_last_name">Last Name</label>
  #        <input aria-labelledby="book_person_last_name_label" class="string person_last_name optional book_person_last_name form-control multi-text-field" id="book_person_last_name" name="book[person][][last_name]" type="text" value="">
  #        <label class="person_role optional control-label" for="book_person_role">Role</label>
  #        <input aria-labelledby="book_person_role_label" class="string person_role optional book_person_role form-control multi-text-field" id="book_person_role" name="book[person][][role]" type="text" value="">
  #      </li>
  #    </ul>
  #  </div>
  #</div>


  def input(wrapper_options)
    @rendered_first_element = false
    input_html_classes.unshift("string")
    input_html_options[:class] << 'multi_value'
    input_html_options[:name] ||= "#{object_name}[#{attribute_name}][]"
    markup = <<-HTML


        <ul class="listing hierarchical">
    HTML


    collection.each_with_index do |person,i|
      unless person.to_s.strip.blank?
        markup << <<-HTML
          <li class="field-wrapper">
            <div class="form-group">
              <label class="col-sm-4 control-label">First Name</label>
              <div class="col-sm-8">
                #{build_text_field(person.first_name.first, 'first_name', i)}
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-4 control-label">Last Name</label>
              <div class="col-sm-8">
                #{build_text_field(person.last_name.first, 'last_name', i)}
            </div>
            </div>
            <div class="form-group">
              <label class="col-sm-4 control-label">Role</label>
              <div class="col-sm-8">
                #{build_text_field(person.role.first, 'role', i)}
            </div>
            </div>
          </li>
        HTML
      end
    end

    markup << <<-HTML
          <li class="field-wrapper">
            <div class="form-group">
              <label class="col-sm-4 control-label">First Name</label>
              <div class="col-sm-8">
                #{build_text_field('', 'first_name', nil)}
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-4 control-label">Last Name</label>
              <div class="col-sm-8">
                #{build_text_field('', 'last_name', nil)}
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-4 control-label">Role</label>
              <div class="col-sm-8">
                #{build_text_field('', 'role', nil)}
              </div>
            </div>
          </li>
        </ul>

    HTML
  end

  private


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
    options[:class] += ["#{input_dom_id(field_name, index)} form-control multi-text-field"]
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
    @collection ||= hierarchical_field_collection(object, attribute_name)
  end

  def multiple?; true; end
end
