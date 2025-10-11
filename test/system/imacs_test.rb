require "application_system_test_case"

class ImacsTest < ApplicationSystemTestCase
  setup do
    @imac = imacs(:one)
  end

  test "visiting the index" do
    visit imacs_url
    assert_selector "h1", text: "Imacs"
  end

  test "creating a Imac" do
    visit imacs_url
    click_on "New Imac"

    fill_in "Diagonal", with: @imac.diagonal
    fill_in "Full title", with: @imac.full_title
    fill_in "Model", with: @imac.model
    fill_in "Overview", with: @imac.overview
    fill_in "Production period", with: @imac.production_period
    fill_in "Series", with: @imac.series
    fill_in "Title", with: @imac.title
    fill_in "Type", with: @imac.type
    fill_in "User", with: @imac.user_id
    click_on "Create Imac"

    assert_text "Imac was successfully created"
    click_on "Back"
  end

  test "updating a Imac" do
    visit imacs_url
    click_on "Edit", match: :first

    fill_in "Diagonal", with: @imac.diagonal
    fill_in "Full title", with: @imac.full_title
    fill_in "Model", with: @imac.model
    fill_in "Overview", with: @imac.overview
    fill_in "Production period", with: @imac.production_period
    fill_in "Series", with: @imac.series
    fill_in "Title", with: @imac.title
    fill_in "Type", with: @imac.type
    fill_in "User", with: @imac.user_id
    click_on "Update Imac"

    assert_text "Imac was successfully updated"
    click_on "Back"
  end

  test "destroying a Imac" do
    visit imacs_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Imac was successfully destroyed"
  end
end
