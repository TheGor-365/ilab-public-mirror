require "test_helper"

class OwnedGadgetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owned_gadget = owned_gadgets(:one)
  end

  test "should get index" do
    get owned_gadgets_url
    assert_response :success
  end

  test "should get new" do
    get new_owned_gadget_url
    assert_response :success
  end

  test "should create owned_gadget" do
    assert_difference('OwnedGadget.count') do
      post owned_gadgets_url, params: { owned_gadget: { phone_id: @owned_gadget.phone_id, user_id: @owned_gadget.user_id } }
    end

    assert_redirected_to owned_gadget_url(OwnedGadget.last)
  end

  test "should show owned_gadget" do
    get owned_gadget_url(@owned_gadget)
    assert_response :success
  end

  test "should get edit" do
    get edit_owned_gadget_url(@owned_gadget)
    assert_response :success
  end

  test "should update owned_gadget" do
    patch owned_gadget_url(@owned_gadget), params: { owned_gadget: { phone_id: @owned_gadget.phone_id, user_id: @owned_gadget.user_id } }
    assert_redirected_to owned_gadget_url(@owned_gadget)
  end

  test "should destroy owned_gadget" do
    assert_difference('OwnedGadget.count', -1) do
      delete owned_gadget_url(@owned_gadget)
    end

    assert_redirected_to owned_gadgets_url
  end
end
