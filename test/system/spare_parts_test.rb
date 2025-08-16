require "application_system_test_case"

class SparePartsTest < ApplicationSystemTestCase
  setup do
    @spare_part = spare_parts(:one)
  end

  test "visiting the index" do
    visit spare_parts_url
    assert_selector "h1", text: "Spare Parts"
  end

  test "creating a Spare part" do
    visit spare_parts_url
    click_on "New Spare Part"

    fill_in "Generation", with: @spare_part.generation_id
    fill_in "Images", with: @spare_part.images
    fill_in "Module", with: @spare_part.module_id
    fill_in "Name", with: @spare_part.name
    fill_in "Phone", with: @spare_part.phone_id
    fill_in "Videos", with: @spare_part.videos
    click_on "Create Spare part"

    assert_text "Spare part was successfully created"
    click_on "Back"
  end

  test "updating a Spare part" do
    visit spare_parts_url
    click_on "Edit", match: :first

    fill_in "Generation", with: @spare_part.generation_id
    fill_in "Images", with: @spare_part.images
    fill_in "Module", with: @spare_part.module_id
    fill_in "Name", with: @spare_part.name
    fill_in "Phone", with: @spare_part.phone_id
    fill_in "Videos", with: @spare_part.videos
    click_on "Update Spare part"

    assert_text "Spare part was successfully updated"
    click_on "Back"
  end

  test "destroying a Spare part" do
    visit spare_parts_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Spare part was successfully destroyed"
  end
end
