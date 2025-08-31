class AnswersController < ApplicationController

  before_action :set_answer, only: %i[ show edit update destroy ]

  def index
    @answers = Answer.all
  end

  def show; end
  def edit; end

  def new
    @answer = Answer.new
  end

  def create
    @answer = Answer.new(answer_params)

    respond_to do |format|
      if @answer.save
        format.html { redirect_to @answer, notice: "Answer was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @answer.update(answer_params)
        format.html { redirect_to @answer, notice: "Answer was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @answer.destroy

    respond_to do |format|
      format.html { redirect_to answers_url, notice: "Answer was successfully destroyed." }
    end
  end

  private

  def set_answer
    @answer = Answer.find(params[:id])
  end

  def answer_params
    params.require(:answer).permit(
      :quiz_question_id,
      :content,
      :correct,
      :avatar,
      :images_cache,
      :avatar_cache,
      { images: [] },
      { videos: [] }
    )
  end
end
