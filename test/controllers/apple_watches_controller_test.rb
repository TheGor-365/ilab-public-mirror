require "test_helper"

class AppleWatchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @apple_watch = apple_watches(:one)
  end

  test "should get index" do
    get apple_watches_url
    assert_response :success
  end

  test "should get new" do
    get new_apple_watch_url
    assert_response :success
  end

  test "should create apple_watch" do
    assert_difference('AppleWatch.count') do
      post apple_watches_url, params: { apple_watch: { diagonal: @apple_watch.diagonal, full_title: @apple_watch.full_title, model: @apple_watch.model, overview: @apple_watch.overview, production_period: @apple_watch.production_period, series: @apple_watch.series, title: @apple_watch.title, user_id: @apple_watch.user_id, version: @apple_watch.version } }
    end

    assert_redirected_to apple_watch_url(AppleWatch.last)
  end

  test "should show apple_watch" do
    get apple_watch_url(@apple_watch)
    assert_response :success
  end

  test "should get edit" do
    get edit_apple_watch_url(@apple_watch)
    assert_response :success
  end

  test "should update apple_watch" do
    patch apple_watch_url(@apple_watch), params: { apple_watch: { diagonal: @apple_watch.diagonal, full_title: @apple_watch.full_title, model: @apple_watch.model, overview: @apple_watch.overview, production_period: @apple_watch.production_period, series: @apple_watch.series, title: @apple_watch.title, user_id: @apple_watch.user_id, version: @apple_watch.version } }
    assert_redirected_to apple_watch_url(@apple_watch)
  end

  test "should destroy apple_watch" do
    assert_difference('AppleWatch.count', -1) do
      delete apple_watch_url(@apple_watch)
    end

    assert_redirected_to apple_watches_url
  end
end
