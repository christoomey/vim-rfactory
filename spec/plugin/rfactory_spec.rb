require 'spec_helper'
require 'json'

describe 'Rfactory' do
  after :each do
    vim.command 'only!'
  end

  context ':Rfactory' do
    %w{create build build_stubbed attributes_for}.each do |method|
      it "maps FactoryBot method '#{method}' to its factory" do
        create_factories_file
        edit_spec_file_with_text "user = #{method}(:user)"

        vim.command 'Rfactory'

        expect(current_path).to eq 'spec/factories.rb'
        expect(current_line).to eq 'factory :user do'
      end

      it "supports the '#{method}_pair' factory method" do
        create_factories_file
        edit_spec_file_with_text "users = #{method}_pair(:user)"

        vim.command 'Rfactory'

        expect(current_line).to eq 'factory :user do'
        expect(current_path).to eq 'spec/factories.rb'
      end

      it "supports the '#{method}_list' factory method" do
        create_factories_file
        edit_spec_file_with_text "users = #{method}_list(:user, 3)"

        vim.command 'Rfactory'

        expect(current_line).to eq 'factory :user do'
        expect(current_path).to eq 'spec/factories.rb'
      end
    end

    it 'navigates to traits if present' do
      create_factories_file
      edit_spec_file_with_text 'user = create(:user, :with_token)'

      vim.command 'Rfactory'

      expect(current_path).to eq 'spec/factories.rb'
      expect(current_line).to eq 'trait :with_token do'
    end

    it 'finds traits in _list FactoryBot method calls' do
      create_factories_file
      edit_spec_file_with_text 'users = create_list(:user, 3, :with_token)'

      vim.command 'Rfactory'

      expect(current_path).to eq 'spec/factories.rb'
      expect(current_line).to eq 'trait :with_token do'
    end

    it 'opens the factories file if no factory call on line' do
      create_factories_file
      edit_spec_file_with_text 'no factory call on this line'

      vim.command 'Rfactory'

      expect(current_path).to eq 'spec/factories.rb'
    end

    it 'does nothing if no factories.rb file is present in spec/ dir' do
      spec_file = create_spec_file('user = create(:user)')

      vim.edit spec_file

      expect { vim.command 'Rfactory' }.not_to change { current_path }
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

  describe "finding the factory" do
    it "finds factories in spec/factories/*.rb" do
      nested_factory_file_path = create_factory_file_in_dir "spec/factories"
      edit_spec_file_with_text

      vim.command "Rfactory"

      expect(current_path).to eq(nested_factory_file_path)
    end

    it "finds factories in test/factories/*.rb" do
      nested_factory_file_path = create_factory_file_in_dir "test/factories"
      edit_spec_file_with_text

      vim.command "Rfactory"

      expect(current_path).to eq(nested_factory_file_path)
    end
  end

  private

  def create_factory_file_in_dir(dir)
    nested_factory_file_path = "#{dir}/user.rb"
    create_factories_file path: "#{dir}/trails.rb", factories_text: ""
    create_factories_file path: nested_factory_file_path
    nested_factory_file_path
  end

  def edit_spec_file_with_text(text = 'user = create :user')
    spec_file = create_spec_file(text)
    vim.edit spec_file
  end

  def switch_window(direction)
    directions  = { 'left' => 'h', 'down' => 'j', 'up' => 'k', 'right' => 'l' }
    vim.command "wincmd #{directions[direction]}"
  end

  def current_line
    vim.command "echo getline('.')"
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

  def create_factories_file(path: "spec/factories.rb", factories_text: nil)
    FileUtils.mkdir_p File.dirname(path)
    factories_text ||= normalize_string_indent <<-EOS
      FactoryBot.define do
        factory :user do
          name 'Bob smith'

          trait :with_token do
            token 'a12bc3fe'
          end
        end
      end
    EOS
    write_file path, factories_text
  end

  def debug!
    puts "\n\n"
    puts vim.command "echo g:rfactory_debug"
    vim.command "let g:rfactory_debug = []"
  end
end
