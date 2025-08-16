require "application_system_test_case"

class DefectsTest < ApplicationSystemTestCase
  setup do
    @defect = defects(:one)
  end

  test "visiting the index" do
    visit defects_url
    assert_selector "h1", text: "defects"
  end

  test "creating a defect" do
    visit defects_url
    click_on "New defect"

    fill_in "Description", with: @defect.description
    fill_in "Reference", with: @defect.reference
    fill_in "Type", with: @defect.type
    click_on "Create defect"

    assert_text "defect was successfully created"
    click_on "Back"
  end

  test "updating a defect" do
    visit defects_url
    click_on "Edit", match: :first

    fill_in "Description", with: @defect.description
    fill_in "Reference", with: @defect.reference
    fill_in "Type", with: @defect.type
    click_on "Update defect"

    assert_text "defect was successfully updated"
    click_on "Back"
  end

  test "destroying a defect" do
    visit defects_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "defect was successfully destroyed"
  end
end
