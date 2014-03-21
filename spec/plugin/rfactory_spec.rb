require 'spec_helper'

describe 'Rfactory' do
  %w{create build build_stubbed attributes_for}.each do |method|
    it "maps FG method '#{method}' to its factory" do
      spec_file = create_spec_file("user = #{method}(:user)")
      create_factories_file(vim.command('pwd'))

      vim.edit spec_file
      vim.command 'Rfactory'

      line = vim.command "echo getline('.')"

      expect(current_path).to eq 'spec/factories.rb'
      expect(line).to eq 'factory :user do'
    end
  end

  it 'navigates to traits if present' do
    spec_file = create_spec_file('user = create(:user, :with_token)')
    create_factories_file(vim.command('pwd'))

    vim.edit spec_file
    vim.command 'Rfactory'

    line = vim.command "echo getline('.')"

    expect(current_path).to eq 'spec/factories.rb'
    expect(line).to eq 'trait :with_token do'
  end

  it 'does nothing if not on a factory call line' do
    spec_file = create_spec_file('no factory call on this line')
    create_factories_file(vim.command('pwd'))

    vim.edit spec_file
    vim.command 'Rfactory'

    expect(current_path).to eq spec_file
  end

  private

  def current_path
    vim.command "echo expand('%')"
  end

  def create_spec_file(text)
    spec_file = 'user_spec.rb'
    write_file(spec_file, text)
    spec_file
  end

  def create_factories_file(path)
    FileUtils.mkdir_p "spec/support"
    factories_path = "spec/factories.rb"
    factories_text = normalize_string_indent <<-EOS
      FactoryGirl.define do
        factory :user do
          name 'Bob smith'

          trait :with_token do
            token 'a12bc3fe'
          end
        end
      end
    EOS
    write_file factories_path, factories_text
  end
end
