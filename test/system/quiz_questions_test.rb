require "application_system_test_case"

class QuizQuestionsTest < ApplicationSystemTestCase
  setup do
    @quiz_question = quiz_questions(:one)
  end

  test "visiting the index" do
    visit quiz_questions_url
    assert_selector "h1", text: "Quiz Questions"
  end

  test "creating a Quiz question" do
    visit quiz_questions_url
    click_on "New Quiz Question"

    fill_in "Content", with: @quiz_question.content
    fill_in "Quiz", with: @quiz_question.quiz_id
    click_on "Create Quiz question"

    assert_text "Quiz question was successfully created"
    click_on "Back"
  end

  test "updating a Quiz question" do
    visit quiz_questions_url
    click_on "Edit", match: :first

    fill_in "Content", with: @quiz_question.content
    fill_in "Quiz", with: @quiz_question.quiz_id
    click_on "Update Quiz question"

    assert_text "Quiz question was successfully updated"
    click_on "Back"
  end

  test "destroying a Quiz question" do
    visit quiz_questions_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Quiz question was successfully destroyed"
  end
end
