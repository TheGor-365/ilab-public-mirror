require "test_helper"

class MakbooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @makbook = makbooks(:one)
  end

  test "should get index" do
    get makbooks_url
    assert_response :success
  end

  test "should get new" do
    get new_makbook_url
    assert_response :success
  end

  test "should create makbook" do
    assert_difference('Makbook.count') do
      post makbooks_url, params: { makbook: { overview: @makbook.overview, title: @makbook.title, user_id: @makbook.user_id } }
    end

    assert_redirected_to makbook_url(Makbook.last)
  end

  test "should show makbook" do
    get makbook_url(@makbook)
    assert_response :success
  end

  test "should get edit" do
    get edit_makbook_url(@makbook)
    assert_response :success
  end

  test "should update makbook" do
    patch makbook_url(@makbook), params: { makbook: { overview: @makbook.overview, title: @makbook.title, user_id: @makbook.user_id } }
    assert_redirected_to makbook_url(@makbook)
  end

  test "should destroy makbook" do
    assert_difference('Makbook.count', -1) do
      delete makbook_url(@makbook)
    end

    assert_redirected_to makbooks_url
  end
end
