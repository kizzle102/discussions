require 'spec_helper'

feature 'Viewing Leader Page' do
  background do
    @discussion = Discussion.create(:title => 'Test Discussion', :leader_code => 'test')
  end

  scenario 'Default/Current Surveys View', :js => true do
    visit discussions_path
    click_link 'Test Discussion'
    click_link 'Leader View'
    find(:xpath, "//input[@name='leader_code']").set 'test'
    click_on 'Submit'

    expect(current_path).to eq "/discussions/#{@discussion.id}/leader"
    expect(page).to have_content 'There are currently no open surveys.'
    expect(page).to have_content 'There are currently no surveys ready to be sent.'
  end

  scenario 'Create a Survey View', :js => true do
    visit discussion_path(@discussion)
    click_link 'Leader View'
    find(:xpath, "//input[@name='leader_code']").set 'test'
    click_on 'Submit'

    click_link 'Create Survey'

    expect(page).to have_content 'Create a New Survey Question:'
    expect(page).to have_xpath("//textarea[@id='question']")
    expect(page).to have_selector("input[type=submit][value='Create Survey']")
    expect(page).to have_selector("input[type=submit][value='Create & Send Survey']")
  end

  scenario 'Ended Surveys View', :js => true do
    visit discussion_path(@discussion)
    click_link 'Leader View'
    find(:xpath, "//input[@name='leader_code']").set 'test'
    click_on 'Submit'

    click_link 'Ended Surveys'

    expect(page).to have_content 'Ended Surveys'
    expect(page).to have_content 'There are currently no ended surveys.'
  end

  scenario 'New Questions View', :js => true do
    visit discussion_path(@discussion)
    click_link 'Leader View'
    find(:xpath, "//input[@name='leader_code']").set 'test'
    click_on 'Submit'

    click_link 'New Questions'

    expect(page).to have_content 'New Participant Questions'
    expect(page).to have_content 'There are currently no new participant questions.'
  end

  scenario 'Answered Questions View', :js => true do
    visit discussion_path(@discussion)
    click_link 'Leader View'
    find(:xpath, "//input[@name='leader_code']").set 'test'
    click_on 'Submit'
    
    click_link 'Answered Questions'

    expect(page).to have_content 'Answered Participant Questions'
    expect(page).to have_content 'There are currently no participant questions that have been answered.'
  end
end