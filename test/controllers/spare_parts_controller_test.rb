require "test_helper"

class SparePartsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @spare_part = spare_parts(:one)
  end

  test "should get index" do
    get spare_parts_url
    assert_response :success
  end

  test "should get new" do
    get new_spare_part_url
    assert_response :success
  end

  test "should create spare_part" do
    assert_difference('SparePart.count') do
      post spare_parts_url, params: { spare_part: { generation_id: @spare_part.generation_id, images: @spare_part.images, module_id: @spare_part.module_id, name: @spare_part.name, phone_id: @spare_part.phone_id, videos: @spare_part.videos } }
    end

    assert_redirected_to spare_part_url(SparePart.last)
  end

  test "should show spare_part" do
    get spare_part_url(@spare_part)
    assert_response :success
  end

  test "should get edit" do
    get edit_spare_part_url(@spare_part)
    assert_response :success
  end

  test "should update spare_part" do
    patch spare_part_url(@spare_part), params: { spare_part: { generation_id: @spare_part.generation_id, images: @spare_part.images, module_id: @spare_part.module_id, name: @spare_part.name, phone_id: @spare_part.phone_id, videos: @spare_part.videos } }
    assert_redirected_to spare_part_url(@spare_part)
  end

  test "should destroy spare_part" do
    assert_difference('SparePart.count', -1) do
      delete spare_part_url(@spare_part)
    end

    assert_redirected_to spare_parts_url
  end
end
