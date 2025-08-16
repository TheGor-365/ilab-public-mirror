require "test_helper"

class ImacsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @imac = imacs(:one)
  end

  test "should get index" do
    get imacs_url
    assert_response :success
  end

  test "should get new" do
    get new_imac_url
    assert_response :success
  end

  test "should create imac" do
    assert_difference('Imac.count') do
      post imacs_url, params: { imac: { diagonal: @imac.diagonal, full_title: @imac.full_title, model: @imac.model, overview: @imac.overview, production_period: @imac.production_period, series: @imac.series, title: @imac.title, type: @imac.type, user_id: @imac.user_id } }
    end

    assert_redirected_to imac_url(Imac.last)
  end

  test "should show imac" do
    get imac_url(@imac)
    assert_response :success
  end

  test "should get edit" do
    get edit_imac_url(@imac)
    assert_response :success
  end

  test "should update imac" do
    patch imac_url(@imac), params: { imac: { diagonal: @imac.diagonal, full_title: @imac.full_title, model: @imac.model, overview: @imac.overview, production_period: @imac.production_period, series: @imac.series, title: @imac.title, type: @imac.type, user_id: @imac.user_id } }
    assert_redirected_to imac_url(@imac)
  end

  test "should destroy imac" do
    assert_difference('Imac.count', -1) do
      delete imac_url(@imac)
    end

    assert_redirected_to imacs_url
  end
end
