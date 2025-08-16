class QuizQuestionsController < ApplicationController

  before_action :set_quiz_question, only: %i[ show edit update destroy ]

  def index
    @quiz_questions = QuizQuestion.all
  end

  def show; end
  def edit; end

  def new
    @quiz_question = QuizQuestion.new
  end

  def create
    @quiz_question = QuizQuestion.new(quiz_question_params)

    respond_to do |format|
      if @quiz_question.save
        format.html { redirect_to @quiz_question, notice: "Quiz question was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @quiz_question.update(quiz_question_params)
        format.html { redirect_to @quiz_question, notice: "Quiz question was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @quiz_question.destroy

    respond_to do |format|
      format.html { redirect_to quiz_questions_url, notice: "Quiz question was successfully destroyed." }
    end
  end

  private

  def set_quiz_question
    @quiz_question = QuizQuestion.find(params[:id])
  end

  def quiz_question_params
    params.require(:quiz_question).permit(
      :quiz_id,
      :content,
      :avatar,
      :images_cache,
      :avatar_cache,
      { images: [] },
      { videos: [] }
    )
  end
end
