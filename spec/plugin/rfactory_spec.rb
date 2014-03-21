require 'spec_helper'

describe 'Rfactory' do
  it 'does things' do
    text = 'user = create(:user)'
    spec_file = 'user_spec.rb'
    file = write_file(spec_file, text)
    create_factories_file(vim.command('pwd'))

    vim.edit spec_file
    vim.command 'Rfactory'

    factories_path = vim.command "echo expand('%')"
    line = vim.command "echo getline('.')"

    expect(factories_path).to eq 'spec/support/factories.rb'
    expect(line).to eq 'factory :user do'
  end

  def create_factories_file(path)
    FileUtils.mkdir_p "#{path}/spec/support"
    factories_path = "#{path}/spec/support/factories.rb"
    factories_text = normalize_string_indent <<-EOS
      FactoryGirl.define do
        factory :user do
          name 'Bob smith'
        end
      end
    EOS
    write_file factories_path, factories_text
  end
end
