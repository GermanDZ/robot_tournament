require 'chronic_duration'

When /^(?:I create )?a(?: new)? Tournament "([^\"]*)" with the following attributes:$/ do |name, table|
  attributes = table.rows_hash
  attributes["name"] = name
  TournamentStore.new.create(attributes).start!
end

Given /^there is a tournament$/ do
  tournament = TournamentStore.new.create(:name => "Test Tournament", :rounds => 3, :duration => 7)
  tournament.start!
end

Then /^I should see that the Tournament "([^\"]*)" is in progress$/ do |name|
  page.should have_content(%{Tournament in Progress: "#{name}"})
end

Then /^I should see that the first Round will begin in less than 10 minutes$/ do
  duration = page.body.scan(/Next round begins in (.*)/).flatten.first
  ChronicDuration.parse(duration).should be < (10 * 60)
end

Then /^I should see that no players are registered for the Round$/ do
  page.should have_content "no players"
end

Then /^I should see that 'always\-paper' is the winner$/ do
  find("//*[@id='winner']").text.should == "always-paper"
end

When /^the engine is kicked$/ do
  tournament.kick
end

Then /^I should see that the tournament has finished$/ do
  page.should have_content "This tournament has finished"
end

Then /^I should see that 2 rounds were played$/ do
  page.all("//*[@class='finished round']").length.should == 2
end

Then /^I should see that 2 matches were played in each round$/ do
  finished_rounds = page.all("//*[@class='finished round']")
  finished_rounds.length.should == 2
  finished_rounds.each do |round|
    round.all("//*[@class='match']").length.should == 2
  end
end