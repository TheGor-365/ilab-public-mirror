require "test_helper"

class DefectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @defect = defects(:one)
  end

  test "should get index" do
    get defects_url
    assert_response :success
  end

  test "should get new" do
    get new_defect_url
    assert_response :success
  end

  test "should create defect" do
    assert_difference('defect.count') do
      post defects_url, params: { defect: { description: @defect.description, reference: @defect.reference, type: @defect.type } }
    end

    assert_redirected_to defect_url(defect.last)
  end

  test "should show defect" do
    get defect_url(@defect)
    assert_response :success
  end

  test "should get edit" do
    get edit_defect_url(@defect)
    assert_response :success
  end

  test "should update defect" do
    patch defect_url(@defect), params: { defect: { description: @defect.description, reference: @defect.reference, type: @defect.type } }
    assert_redirected_to defect_url(@defect)
  end

  test "should destroy defect" do
    assert_difference('defect.count', -1) do
      delete defect_url(@defect)
    end

    assert_redirected_to defects_url
  end
end
