require "application_system_test_case"

class AppleWatchesTest < ApplicationSystemTestCase
  setup do
    @apple_watch = apple_watches(:one)
  end

  test "visiting the index" do
    visit apple_watches_url
    assert_selector "h1", text: "Apple Watches"
  end

  test "creating a Apple watch" do
    visit apple_watches_url
    click_on "New Apple Watch"

    fill_in "Diagonal", with: @apple_watch.diagonal
    fill_in "Full title", with: @apple_watch.full_title
    fill_in "Model", with: @apple_watch.model
    fill_in "Overview", with: @apple_watch.overview
    fill_in "Production period", with: @apple_watch.production_period
    fill_in "Series", with: @apple_watch.series
    fill_in "Title", with: @apple_watch.title
    fill_in "User", with: @apple_watch.user_id
    fill_in "Version", with: @apple_watch.version
    click_on "Create Apple watch"

    assert_text "Apple watch was successfully created"
    click_on "Back"
  end

  test "updating a Apple watch" do
    visit apple_watches_url
    click_on "Edit", match: :first

    fill_in "Diagonal", with: @apple_watch.diagonal
    fill_in "Full title", with: @apple_watch.full_title
    fill_in "Model", with: @apple_watch.model
    fill_in "Overview", with: @apple_watch.overview
    fill_in "Production period", with: @apple_watch.production_period
    fill_in "Series", with: @apple_watch.series
    fill_in "Title", with: @apple_watch.title
    fill_in "User", with: @apple_watch.user_id
    fill_in "Version", with: @apple_watch.version
    click_on "Update Apple watch"

    assert_text "Apple watch was successfully updated"
    click_on "Back"
  end

  test "destroying a Apple watch" do
    visit apple_watches_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Apple watch was successfully destroyed"
  end
end
