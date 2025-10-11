require "application_system_test_case"

class GenerationsTest < ApplicationSystemTestCase
  setup do
    @generation = generations(:one)
  end

  test "visiting the index" do
    visit generations_url
    assert_selector "h1", text: "Generations"
  end

  test "creating a Generation" do
    visit generations_url
    click_on "New Generation"

    fill_in "Phone", with: @generation.phone_id
    fill_in "Title", with: @generation.title
    click_on "Create Generation"

    assert_text "Generation was successfully created"
    click_on "Back"
  end

  test "updating a Generation" do
    visit generations_url
    click_on "Edit", match: :first

    fill_in "Phone", with: @generation.phone_id
    fill_in "Title", with: @generation.title
    click_on "Update Generation"

    assert_text "Generation was successfully updated"
    click_on "Back"
  end

  test "destroying a Generation" do
    visit generations_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Generation was successfully destroyed"
  end
end
