require "test_helper"

class VideoRecordingsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get video_recordings_new_url
    assert_response :success
  end
end
