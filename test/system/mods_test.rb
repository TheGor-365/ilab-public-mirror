require "application_system_test_case"

class ModsTest < ApplicationSystemTestCase
  setup do
    @mod = mods(:one)
  end

  test "visiting the index" do
    visit mods_url
    assert_selector "h1", text: "Modules"
  end

  test "creating a Module" do
    visit mods_url
    click_on "New Module"

    fill_in "Generation", with: @mod.generation_id
    fill_in "Image", with: @mod.image
    fill_in "Model", with: @mod.model_id
    fill_in "Name", with: @mod.name
    fill_in "Phone", with: @mod.phone_id
    click_on "Create Module"

    assert_text "Module was successfully created"
    click_on "Back"
  end

  test "updating a Module" do
    visit mods_url
    click_on "Edit", match: :first

    fill_in "Generation", with: @mod.generation_id
    fill_in "Image", with: @mod.image
    fill_in "Model", with: @mod.model_id
    fill_in "Name", with: @mod.name
    fill_in "Phone", with: @mod.phone_id
    click_on "Update Module"

    assert_text "Module was successfully updated"
    click_on "Back"
  end

  test "destroying a Module" do
    visit mods_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Module was successfully destroyed"
  end
end
