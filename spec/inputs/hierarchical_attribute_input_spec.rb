require 'rails_helper'
require 'simple_form'

describe HierarchicalAttributeInput, type: :view do

  let(:book) { FactoryGirl.create(:kind_of_blue) }

  it "should render a field set that includes inputs for all of the attribute's subfields" do
    render partial: 'curation_concern/base/form', locals: { curation_concern: book }
    expect(rendered).to have_css("div.book_person ul.listing.hierarchical li.field-wrapper", count:3)
    expect(rendered).to have_field("book_person_0_first_name", with: "Miles" )
    expect(rendered).to have_xpath("//input[@name = 'book[person][][first_name]'][@value = 'Miles']")
  end
end
