require "application_system_test_case"

class IpadsTest < ApplicationSystemTestCase
  setup do
    @ipad = ipads(:one)
  end

  test "visiting the index" do
    visit ipads_url
    assert_selector "h1", text: "Ipads"
  end

  test "creating a Ipad" do
    visit ipads_url
    click_on "New Ipad"

    fill_in "Diagonal", with: @ipad.diagonal
    fill_in "Full title", with: @ipad.full_title
    fill_in "Model", with: @ipad.model
    fill_in "Overview", with: @ipad.overview
    fill_in "Production period", with: @ipad.production_period
    fill_in "Series", with: @ipad.series
    fill_in "Title", with: @ipad.title
    fill_in "User", with: @ipad.user_id
    fill_in "Version", with: @ipad.version
    click_on "Create Ipad"

    assert_text "Ipad was successfully created"
    click_on "Back"
  end

  test "updating a Ipad" do
    visit ipads_url
    click_on "Edit", match: :first

    fill_in "Diagonal", with: @ipad.diagonal
    fill_in "Full title", with: @ipad.full_title
    fill_in "Model", with: @ipad.model
    fill_in "Overview", with: @ipad.overview
    fill_in "Production period", with: @ipad.production_period
    fill_in "Series", with: @ipad.series
    fill_in "Title", with: @ipad.title
    fill_in "User", with: @ipad.user_id
    fill_in "Version", with: @ipad.version
    click_on "Update Ipad"

    assert_text "Ipad was successfully updated"
    click_on "Back"
  end

  test "destroying a Ipad" do
    visit ipads_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Ipad was successfully destroyed"
  end
end
