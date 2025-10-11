require "application_system_test_case"

class MakbooksTest < ApplicationSystemTestCase
  setup do
    @makbook = makbooks(:one)
  end

  test "visiting the index" do
    visit makbooks_url
    assert_selector "h1", text: "Makbooks"
  end

  test "creating a Makbook" do
    visit makbooks_url
    click_on "New Makbook"

    fill_in "Overview", with: @makbook.overview
    fill_in "Title", with: @makbook.title
    fill_in "User", with: @makbook.user_id
    click_on "Create Makbook"

    assert_text "Makbook was successfully created"
    click_on "Back"
  end

  test "updating a Makbook" do
    visit makbooks_url
    click_on "Edit", match: :first

    fill_in "Overview", with: @makbook.overview
    fill_in "Title", with: @makbook.title
    fill_in "User", with: @makbook.user_id
    click_on "Update Makbook"

    assert_text "Makbook was successfully updated"
    click_on "Back"
  end

  test "destroying a Makbook" do
    visit makbooks_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Makbook was successfully destroyed"
  end
end
