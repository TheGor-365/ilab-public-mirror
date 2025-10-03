require "application_system_test_case"

class AirpodsTest < ApplicationSystemTestCase
  setup do
    @airpod = airpods(:one)
  end

  test "visiting the index" do
    visit airpods_url
    assert_selector "h1", text: "Airpods"
  end

  test "creating a Airpod" do
    visit airpods_url
    click_on "New Airpod"

    fill_in "Diagonal", with: @airpod.diagonal
    fill_in "Full title", with: @airpod.full_title
    fill_in "Model", with: @airpod.model
    fill_in "Overview", with: @airpod.overview
    fill_in "Production period", with: @airpod.production_period
    fill_in "Series", with: @airpod.series
    fill_in "Title", with: @airpod.title
    fill_in "User", with: @airpod.user_id
    fill_in "Version", with: @airpod.version
    click_on "Create Airpod"

    assert_text "Airpod was successfully created"
    click_on "Back"
  end

  test "updating a Airpod" do
    visit airpods_url
    click_on "Edit", match: :first

    fill_in "Diagonal", with: @airpod.diagonal
    fill_in "Full title", with: @airpod.full_title
    fill_in "Model", with: @airpod.model
    fill_in "Overview", with: @airpod.overview
    fill_in "Production period", with: @airpod.production_period
    fill_in "Series", with: @airpod.series
    fill_in "Title", with: @airpod.title
    fill_in "User", with: @airpod.user_id
    fill_in "Version", with: @airpod.version
    click_on "Update Airpod"

    assert_text "Airpod was successfully updated"
    click_on "Back"
  end

  test "destroying a Airpod" do
    visit airpods_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Airpod was successfully destroyed"
  end
end
