require 'rails_helper'

describe 'curation_concern/base/form.html.erb' do

  let(:book) { FactoryGirl.create(:book) }

  it "" do
    render partial: 'curation_concern/base/form', locals: { curation_concern: book }
  end

end