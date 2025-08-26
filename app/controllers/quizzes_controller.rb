class QuizzesController < ApplicationController

  before_action :set_quiz, only: %i[ show edit update destroy ]

  def index
    @quizzes = Quiz.all
  end

  def show; end
  def edit; end

  def new
    @quiz = Quiz.new
  end

  def create
    @quiz = Quiz.new(quiz_params)

    respond_to do |format|
      if @quiz.save
        format.html { redirect_to @quiz, notice: "Quiz was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @quiz.update(quiz_params)
        format.html { redirect_to @quiz, notice: "Quiz was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @quiz.destroy

    respond_to do |format|
      format.html { redirect_to quizzes_url, notice: "Quiz was successfully destroyed." }
    end
  end

  private

  def set_quiz
    @quiz = Quiz.find(params[:id])
  end

  def quiz_params
    params.require(:quiz).permit(
      :cource_id,
      :chapter_id,
      :name,
      :description,
      :passing_score,
      :num_questions_to_show,
      :avatar,
      :images_cache,
      :avatar_cache,
      { images: [] },
      { videos: [] }
    )
  end
end
