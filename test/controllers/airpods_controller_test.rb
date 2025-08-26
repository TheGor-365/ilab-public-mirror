require "test_helper"

class AirpodsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @airpod = airpods(:one)
  end

  test "should get index" do
    get airpods_url
    assert_response :success
  end

  test "should get new" do
    get new_airpod_url
    assert_response :success
  end

  test "should create airpod" do
    assert_difference('Airpod.count') do
      post airpods_url, params: { airpod: { diagonal: @airpod.diagonal, full_title: @airpod.full_title, model: @airpod.model, overview: @airpod.overview, production_period: @airpod.production_period, series: @airpod.series, title: @airpod.title, user_id: @airpod.user_id, version: @airpod.version } }
    end

    assert_redirected_to airpod_url(Airpod.last)
  end

  test "should show airpod" do
    get airpod_url(@airpod)
    assert_response :success
  end

  test "should get edit" do
    get edit_airpod_url(@airpod)
    assert_response :success
  end

  test "should update airpod" do
    patch airpod_url(@airpod), params: { airpod: { diagonal: @airpod.diagonal, full_title: @airpod.full_title, model: @airpod.model, overview: @airpod.overview, production_period: @airpod.production_period, series: @airpod.series, title: @airpod.title, user_id: @airpod.user_id, version: @airpod.version } }
    assert_redirected_to airpod_url(@airpod)
  end

  test "should destroy airpod" do
    assert_difference('Airpod.count', -1) do
      delete airpod_url(@airpod)
    end

    assert_redirected_to airpods_url
  end
end
