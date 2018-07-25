require_relative './rfactory'

should_match = <<~TEST_CASE
  create(:subscriber, :with_full_subscription, :needs_onboarding)
TEST_CASE

should_not_match = <<~TEST_CASE
  sign_in_as
TEST_CASE

tricky_should_not_match = <<~TEST_CASE
  expect(page).to have_content(I18n.t("pages.welcome.headline"))
TEST_CASE

nested_should_match = <<~TEST_CASE
  user = create(:subscriber, :with_full_subscription, :needs_onboarding)
  sign_in_as user

  visit root_path
TEST_CASE

[
  [:should_match, should_match, 1],
  [:should_not_match, should_not_match, 0],
  [:tricky_should_not_match, tricky_should_not_match, 0],
  [:nested_should_match, nested_should_match, 1],
].each do |test_name, test_case, expected_result|
  send_nodes = Rfactory::Processor.find_send_nodes(test_case)

  if send_nodes.select(&:building_factory?).count == expected_result
    puts "#{test_name} passed!"
  else
    puts "#{test_name} failed! Expected #{expected_result}."
  end
end

send_nodes = Rfactory::FactoryFinder.new.factory_calls(File.read('./lib/sample.rb'))

if send_nodes.count == 2
  puts "File parsing passed!"
else
  puts "File parsing failed! Expected #{expected_result}."
end


factory = Rfactory::FactoryFinder.find_in_file('./lib/sample.rb', 14, 20)

if factory == :subscriber
  puts "Found the correct factory! Hooray!"
else
  puts ":( Factory not found."
end
