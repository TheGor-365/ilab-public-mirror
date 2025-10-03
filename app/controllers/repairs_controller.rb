class RepairsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_repair, only: %i[ show edit update destroy ]

  def index
    scope = Repair.all

    # Контекст для шапки
    @generation = Generation.find_by(id: params[:generation_id]) if params[:generation_id].present?
    @phone      = Phone.find_by(id: params[:phone_id])           if params[:phone_id].present?
    @model      = Model.find_by(id: params[:model_id])           if params[:model_id].present?

    # ===== Расширенные фильтры =====
    # По модели — через моды (как и было)
    if params[:model_id].present?
      scope = scope.joins(:mods).where(mods: { model_id: params[:model_id] })
    end

    # По продукту — через product_repairs (как и было)
    if params[:product_id].present?
      scope = scope.joins(:products).where(products: { id: params[:product_id] })
    end

    # По поколению — либо колонка в repairs, либо у модов
    if params[:generation_id].present?
      gid = params[:generation_id].to_i
      scope = scope.left_joins(:mods)
                   .where('repairs.generation_id = :gid OR mods.generation_id = :gid', gid: gid)
    end

    # По телефону — либо колонка в repairs, либо HABTM phones
    if params[:phone_id].present?
      pid = params[:phone_id].to_i
      scope = scope.left_joins(:phones)
                   .where('repairs.phone_id = :pid OR phones.id = :pid', pid: pid)
    end

    # Подгрузки для карточек/деталей
    scope = scope.includes(:mods, :phones)

    @repairs = scope.distinct.order(:id).page(params[:page]).per(24) rescue scope.limit(100)
  end

  def show
    respond_to do |format|
      format.html
    end
  end

  def edit; end

  def new
    @repair = Repair.new
  end

  def create
    @repair = Repair.new(repair_params)

    respond_to do |format|
      if @repair.save
        format.html { redirect_to @repair, notice: "Repair was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @repair.update(repair_params)
        format.html { redirect_to @repair, notice: "Repair was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @repair.destroy
    respond_to do |format|
      format.html { redirect_to repairs_url, notice: "Repair was successfully destroyed." }
    end
  end

  private

  def set_repair
    @repair = Repair.find(params[:id])
  end

  def repair_params
    params.require(:repair).permit(
      :generation_id, :phone_id, :defect_id, :mod_id,
      :title, :description, :overview, :avatar, :price,
      spare_parts: [], images: [], videos: []
    )
  end
end
