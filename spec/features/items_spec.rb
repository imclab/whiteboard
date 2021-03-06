require 'spec_helper'

describe "items", type: :request, js: true do
  let!(:standup) { FactoryGirl.create(:standup, title: 'San Francisco', subject_prefix: "[Standup][SF]", closing_message: 'Woohoo') }
  let!(:other_standup) { FactoryGirl.create(:standup, title: 'New York') }

  before do
    login
    visit '/'
    click_link(standup.title)

    find('a[data-kind="New face"] i').click
    fill_in 'item_title', :with => "Fred Flintstone"
    select 'New York', :from => 'item[standup_id]'
    click_button 'Create New Face'

    find('a[data-kind="New face"] i').click
    fill_in 'item_title', :with => "Johnathon McKenzie"
    select 'San Francisco', from: 'item[standup_id]'
    click_button 'Create New Face'

    find('a[data-kind="New face"] i').click
    fill_in 'item_title', :with => "Jane Doe"
    fill_in 'item_date', :with => 5.days.from_now.to_date.strftime("%Y-%m-%d")
    select 'San Francisco', from: 'item[standup_id]'
    click_button 'Create New Face'

    find('a[data-kind="Event"] i').click
    fill_in 'item_title', :with => "Meetup"
    fill_in 'item_date', :with => 5.days.from_now.to_date.strftime("%Y-%m-%d")
    select 'New York', from: 'item[standup_id]'
    click_button 'Create Item'

    find('a[data-kind="Event"] i').click
    fill_in 'item_title', :with => "Party"
    fill_in 'item_date', :with => 5.days.from_now.to_date.strftime("%Y-%m-%d")
    select 'San Francisco', from: 'item[standup_id]'
    click_button 'Create Item'

    find('a[data-kind="Event"] i').click
    fill_in 'item_title', :with => "Happy Hour"
    fill_in 'item_date', :with => Time.now.to_date.strftime("%Y-%m-%d")
    select 'San Francisco', from: 'item[standup_id]'
    click_button 'Create Item'

    find('a[data-kind="Event"] i').click
    fill_in 'item_title', :with => "Baseball"
    fill_in 'item_date', :with => 1.day.from_now.to_date.strftime("%Y-%m-%d")
    select 'San Francisco', from: 'item[standup_id]'
    click_button 'Create Item'

    find('a[data-kind="Interesting"] i').click
    fill_in 'item_title', :with => "Linux 3.2 out"
    fill_in 'item_author', :with => "Linus Torvalds"
    fill_in 'item_description', with: "Check it out!"
    click_button 'Create Item'

    find('a[data-kind="Event"] i').click
    click_button('Interesting')
    fill_in 'item_title', :with => "Rails 62 is out"
    fill_in 'item_author', :with => "DHH"
    fill_in 'item_description', with: "Now with more f-bombs"
    click_button 'Create Item'
  end

  it 'deck.js for standup' do
    visit '/'
    click_link(standup.title)
    page.should have_css('.subheader.today', text: 'Today')
    page.should have_css('.today + .item', text: 'Happy Hour')
    page.should have_css('.subheader.tomorrow', text: 'Tomorrow')
    page.should have_css('.tomorrow + .item', text: 'Baseball')
    page.should have_css('.subheader.upcoming', text: 'Upcoming')
    page.should have_css('.upcoming + .item', text: 'Party')

    visit presentation_standup_items_path(standup)
    find('section.deck-current').should have_content "Standup"
    find('section.deck-current').should have_css "[data-countdown-date]"
    page.execute_script("$.deck('next')")

    find('section.deck-current').should have_content "New faces"
    find('section.deck-current').should have_content "Johnathon McKenzie"
    page.execute_script("$.deck('next')")

    find('section.deck-current').should have_content "Helps"
    page.execute_script("$.deck('next')")

    find('section.deck-current').should have_content "Interestings"
    find('section.deck-current').should have_content("Linux 3.2 out")
    find('section.deck-current').should have_content("Linus Torvalds")
    find('section.deck-current').should have_content("Rails 62 is out")
    find('section.deck-current').should_not have_selector('.in')
    first('section.deck-current a[data-toggle]').click
    find('section.deck-current').should have_selector('.in')
    page.execute_script("$.deck('next')")

    find('section.deck-current').should have_content "Events"
    page.should have_css('section.deck-current', text: 'Today')
    page.should have_css('.today + ul li', text: 'Happy Hour')
    page.should have_css('section.deck-current', text: 'Tomorrow')
    page.should have_css('.tomorrow + ul li', text: 'Baseball')
    page.should have_css('section.deck-current', text: 'Upcoming')
    page.should have_css('.upcoming + ul li', text: 'Party')
    find('section.deck-current').should_not have_content "Meetup"
    find('section.deck-current').should_not have_content("Rails 62 is out")
    page.execute_script("$.deck('next')")

    find('section.deck-current').should_not have_content "Events"
    find('section.deck-current').should have_content "Woohoo"

    all('.exit-presentation').first.click

    current_path.should == standup_items_path(standup)
  end
end
