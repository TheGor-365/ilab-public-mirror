require "test_helper"

class IpadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ipad = ipads(:one)
  end

  test "should get index" do
    get ipads_url
    assert_response :success
  end

  test "should get new" do
    get new_ipad_url
    assert_response :success
  end

  test "should create ipad" do
    assert_difference('Ipad.count') do
      post ipads_url, params: { ipad: { diagonal: @ipad.diagonal, full_title: @ipad.full_title, model: @ipad.model, overview: @ipad.overview, production_period: @ipad.production_period, series: @ipad.series, title: @ipad.title, user_id: @ipad.user_id, version: @ipad.version } }
    end

    assert_redirected_to ipad_url(Ipad.last)
  end

  test "should show ipad" do
    get ipad_url(@ipad)
    assert_response :success
  end

  test "should get edit" do
    get edit_ipad_url(@ipad)
    assert_response :success
  end

  test "should update ipad" do
    patch ipad_url(@ipad), params: { ipad: { diagonal: @ipad.diagonal, full_title: @ipad.full_title, model: @ipad.model, overview: @ipad.overview, production_period: @ipad.production_period, series: @ipad.series, title: @ipad.title, user_id: @ipad.user_id, version: @ipad.version } }
    assert_redirected_to ipad_url(@ipad)
  end

  test "should destroy ipad" do
    assert_difference('Ipad.count', -1) do
      delete ipad_url(@ipad)
    end

    assert_redirected_to ipads_url
  end
end
