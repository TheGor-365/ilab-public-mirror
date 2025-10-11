require "application_system_test_case"

class OwnedGadgetsTest < ApplicationSystemTestCase
  setup do
    @owned_gadget = owned_gadgets(:one)
  end

  test "visiting the index" do
    visit owned_gadgets_url
    assert_selector "h1", text: "Owned Gadgets"
  end

  test "creating a Owned gadget" do
    visit owned_gadgets_url
    click_on "New Owned Gadget"

    fill_in "Phone", with: @owned_gadget.phone_id
    fill_in "User", with: @owned_gadget.user_id
    click_on "Create Owned gadget"

    assert_text "Owned gadget was successfully created"
    click_on "Back"
  end

  test "updating a Owned gadget" do
    visit owned_gadgets_url
    click_on "Edit", match: :first

    fill_in "Phone", with: @owned_gadget.phone_id
    fill_in "User", with: @owned_gadget.user_id
    click_on "Update Owned gadget"

    assert_text "Owned gadget was successfully updated"
    click_on "Back"
  end

  test "destroying a Owned gadget" do
    visit owned_gadgets_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Owned gadget was successfully destroyed"
  end
end
