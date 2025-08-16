require "test_helper"

class ModsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mod = mods(:one)
  end

  test "should get index" do
    get mods_url
    assert_response :success
  end

  test "should get new" do
    get new_mod_url
    assert_response :success
  end

  test "should create module" do
    assert_difference('Module.count') do
      post mods_url, params: { mod: { generation_id: @mod.generation_id, image: @mod.image, model_id: @mod.model_id, name: @mod.name, phone_id: @mod.phone_id } }
    end

    assert_redirected_to mod_url(Mod.last)
  end

  test "should show module" do
    get mod_url(@mod)
    assert_response :success
  end

  test "should get edit" do
    get edit_mod_url(@mod)
    assert_response :success
  end

  test "should update module" do
    patch mod_url(@mod), params: { mod: { generation_id: @mod.generation_id, image: @mod.image, model_id: @mod.model_id, name: @mod.name, phone_id: @mod.phone_id } }
    assert_redirected_to mod_url(@mod)
  end

  test "should destroy module" do
    assert_difference('Module.count', -1) do
      delete mod_url(@mod)
    end

    assert_redirected_to mods_url
  end
end
