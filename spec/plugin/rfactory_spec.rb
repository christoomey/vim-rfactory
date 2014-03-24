require 'spec_helper'
require 'json'

describe 'Rfactory' do
  after :each do
    vim.command 'only!'
  end

  context ':Rfactory' do
    %w{create build build_stubbed attributes_for}.each do |method|
      it "maps FG method '#{method}' to its factory" do
        create_factories_file
        edit_spec_file_with_text "user = #{method}(:user)"

        vim.command 'Rfactory'

        expect(current_path).to eq 'spec/factories.rb'
        expect(current_line).to eq 'factory :user do'
      end
    end

    it 'navigates to traits if present' do
      create_factories_file
      edit_spec_file_with_text 'user = create(:user, :with_token)'

      vim.command 'Rfactory'

      expect(current_path).to eq 'spec/factories.rb'
      expect(current_line).to eq 'trait :with_token do'
    end

    it 'does nothing if not on a factory call line' do
      create_factories_file
      edit_spec_file_with_text 'no factory call on this line'

      vim.command 'Rfactory'

      expect(current_path).to eq 'user_spec.rb'
    end

    it 'uses the factory location override if present' do
      create_factories_file 'spec/support'
      edit_spec_file_with_text

      with_factory_file_location("spec/support/factories.rb") do
        vim.command 'Rfactory'

        expect(current_path).to eq 'spec/support/factories.rb'
        expect(current_line).to eq 'factory :user do'
      end
    end
  end

  context ':REfactory' do
    it 'opens the factory in the current window' do
      create_factories_file
      edit_spec_file_with_text

      vim.command 'REfactory'

      expect(current_path).to eq 'spec/factories.rb'
      expect(visible_buffers.length).to eq 1
    end
  end

  context ':RSfactory' do
    it 'opens the factory in a split' do
      create_factories_file
      edit_spec_file_with_text

      vim.command 'RSfactory'

      expect(current_path).to eq 'spec/factories.rb'
      expect(visible_buffers.length).to eq 2

      expect { switch_window('right') }.not_to change { current_path }
      expect { switch_window('down') }.to change { current_path }
    end
  end

  context ':RVfactory' do
    it 'opens the factory file in a vertical split' do
      create_factories_file
      edit_spec_file_with_text

      vim.command 'RVfactory'

      expect(current_path).to eq 'spec/factories.rb'
      expect(visible_buffers.length).to eq 2

      expect { switch_window('down') }.not_to change { current_path }
      expect { switch_window('right') }.to change { current_path }
    end
  end

  context ':RTfactory' do
    it 'opens the factory file in a new tab' do
      create_factories_file
      edit_spec_file_with_text

      vim.command 'RTfactory'

      expect(current_path).to eq 'spec/factories.rb'
      expect(current_tab_number).to eq '2'
      expect(visible_buffers.length).to eq 1

      vim.command 'tabclose'
      expect(current_path).to eq 'user_spec.rb'
      expect(current_tab_number).to eq '1'
    end
  end

  private

  def edit_spec_file_with_text(text =' user = create :user')
    spec_file = create_spec_file(text)
    vim.edit spec_file
  end

  def switch_window(direction)
    directions  = { 'left' => 'h', 'down' => 'j', 'up' => 'k', 'right' => 'l' }
    vim.command "wincmd #{directions[direction]}"
  end

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

  def current_window
    vim.command 'echo winnr()'
  end

  def visible_buffers
    JSON.parse vim.command "echo tabpagebuflist(tabpagenr())"
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
