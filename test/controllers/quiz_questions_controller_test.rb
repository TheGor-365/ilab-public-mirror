require "test_helper"

class QuizQuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @quiz_question = quiz_questions(:one)
  end

  test "should get index" do
    get quiz_questions_url
    assert_response :success
  end

  test "should get new" do
    get new_quiz_question_url
    assert_response :success
  end

  test "should create quiz_question" do
    assert_difference('QuizQuestion.count') do
      post quiz_questions_url, params: { quiz_question: { content: @quiz_question.content, quiz_id: @quiz_question.quiz_id } }
    end

    assert_redirected_to quiz_question_url(QuizQuestion.last)
  end

  test "should show quiz_question" do
    get quiz_question_url(@quiz_question)
    assert_response :success
  end

  test "should get edit" do
    get edit_quiz_question_url(@quiz_question)
    assert_response :success
  end

  test "should update quiz_question" do
    patch quiz_question_url(@quiz_question), params: { quiz_question: { content: @quiz_question.content, quiz_id: @quiz_question.quiz_id } }
    assert_redirected_to quiz_question_url(@quiz_question)
  end

  test "should destroy quiz_question" do
    assert_difference('QuizQuestion.count', -1) do
      delete quiz_question_url(@quiz_question)
    end

    assert_redirected_to quiz_questions_url
  end
end
