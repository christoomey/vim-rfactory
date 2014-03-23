require 'spec_helper'

describe 'Rfactory' do
  %w{create build build_stubbed attributes_for}.each do |method|
    it "maps FG method '#{method}' to its factory" do
      spec_file = create_spec_file("user = #{method}(:user)")
      create_factories_file

      vim.edit spec_file
      vim.command 'Rfactory'

      expect(current_path).to eq 'spec/factories.rb'
      expect(current_line).to eq 'factory :user do'
    end
  end

  it 'navigates to traits if present' do
    spec_file = create_spec_file('user = create(:user, :with_token)')
    create_factories_file

    vim.edit spec_file
    vim.command 'Rfactory'

    expect(current_path).to eq 'spec/factories.rb'
    expect(current_line).to eq 'trait :with_token do'
  end

  it 'does nothing if not on a factory call line' do
    spec_file = create_spec_file('no factory call on this line')
    create_factories_file

    vim.edit spec_file
    vim.command 'Rfactory'

    expect(current_path).to eq spec_file
  end

  it 'uses the factory location overrid if present' do
    spec_file = create_spec_file('user = create(:user)')
    create_factories_file('spec/support')

    with_factory_file_location("spec/support/factories.rb") do
      vim.edit spec_file
      vim.command 'Rfactory'

      expect(current_path).to eq 'spec/support/factories.rb'
      expect(current_line).to eq 'factory :user do'
    end
  end

  it 'navigates via the deisred edit mehtod per command' do
    spec_file = create_spec_file('user = create :user')
    create_factories_file

    vim.edit spec_file
    vim.command 'RTfactory'

    expect(current_path).to eq 'spec/factories.rb'
    expect(current_tab_number).to eq '2'

    vim.command 'tabclose'
    expect(current_path).to eq 'user_spec.rb'
    expect(current_tab_number).to eq '1'
  end

  private

  def with_factory_file_location(location)
    default_location = vim.command 'echo g:rfactory_factory_location'
    vim.command "let g:rfactory_factory_location = '#{location}'"
    yield
  ensure
    vim.command "let g:rfactory_factory_location = '#{default_location}'"
  end

  def current_line
    line = vim.command "echo getline('.')"
  end

  def current_path
    vim.command "echo expand('%')"
  end

  def current_tab_number
    vim.command 'echo tabpagenr()'
  end

  def create_spec_file(text)
    spec_file = 'user_spec.rb'
    write_file(spec_file, text)
    spec_file
  end

  def create_factories_file(path='spec')
    FileUtils.mkdir_p path
    factories_path = "#{path}/factories.rb"
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
