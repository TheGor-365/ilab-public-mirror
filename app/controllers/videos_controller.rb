class VideosController < ApplicationController

  before_action :set_phone
  before_action :set_defect
  before_action :set_generation
  before_action :set_repair
  before_action :set_model
  before_action :set_mod
  before_action :set_spare_part
  before_action :set_makbook
  before_action :set_imac
  before_action :set_pad
  before_action :set_airpod
  before_action :set_apple_watch

  def create
    add_more_videos(videos_params[:videos])

    case toastr_flash[:error]
    when @phone
      toastr_flash[:error] = "Failed uploading videos" unless @phone.save
    when @defect
      toastr_flash[:error] = "Failed uploading videos" unless @defect.save
    when @generation
      toastr_flash[:error] = "Failed uploading videos" unless @generation.save
    when @repair
      toastr_flash[:error] = "Failed uploading videos" unless @repair.save
    when @model
      toastr_flash[:error] = "Failed uploading videos" unless @model.save
    when @mod
      toastr_flash[:error] = "Failed uploading videos" unless @mod.save
    when @spare_part
      toastr_flash[:error] = "Failed uploading videos" unless @spare_part.save
    when @makbook
      toastr_flash[:error] = "Failed uploading videos" unless @makbook.save
    when @imac
      toastr_flash[:error] = "Failed uploading videos" unless @imac.save
    when @ipad
      toastr_flash[:error] = "Failed uploading videos" unless @ipad.save
    when @airpod
      toastr_flash[:error] = "Failed uploading videos" unless @airpod.save
    when @apple_watch
      toastr_flash[:error] = "Failed uploading videos" unless @apple_watch.save
    end

    redirect_to :back
  end

  def destroy
    remove_video_at_index(params[:id].to_i)

    case toastr_flash[:error]
    when @phone
      toastr_flash[:error] = "Failed deleting video" unless @phone.save
    when @defect
      toastr_flash[:error] = "Failed deleting video" unless @defect.save
    when @generation
      toastr_flash[:error] = "Failed deleting video" unless @generation.save
    when @repair
      toastr_flash[:error] = "Failed deleting video" unless @repair.save
    when @model
      toastr_flash[:error] = "Failed deleting video" unless @model.save
    when @mod
      toastr_flash[:error] = "Failed deleting video" unless @mod.save
    when @spare_part
      toastr_flash[:error] = "Failed deleting video" unless @spare_part.save
    when @makbook
      toastr_flash[:error] = "Failed deleting video" unless @makbook.save
    when @imac
      toastr_flash[:error] = "Failed deleting video" unless @imac.save
    when @ipad
      toastr_flash[:error] = "Failed deleting video" unless @ipad.save
    when @airpod
      toastr_flash[:error] = "Failed deleting video" unless @airpod.save
    when @apple_watch
      toastr_flash[:error] = "Failed deleting video" unless @apple_watch.save
    end

    redirect_to :back
  end

  private

  def set_phone
    @phone = Phone.find(params[:phone_id])
  end

  def set_defect
    @defect = Defect.find(params[:defect_id])
  end

  def set_generation
    @generation = Generation.find(params[:generation_id])
  end

  def set_repair
    @repair = Repair.find(params[:repair_id])
  end

  def set_model
    @model = Model.find(params[:model_id])
  end

  def set_mod
    @mod = Mod.find(params[:mod_id])
  end

  def set_spare_part
    @spare_part = SparePart.find(params[:spare_part_id])
  end

  def set_makbook
    @makbook = Makbook.find(params[:makbook_id])
  end

  def set_imac
    @imac = Imac.find(params[:imac_id])
  end

  def set_ipad
    @ipad = Ipad.find(params[:ipad_id])
  end

  def set_airpod
    @airpod = Airpod.find(params[:airpod_id])
  end

  def set_apple_watch
    @apple_watch = AppleWatch.find(params[:apple_watch_id])
  end

  def add_more_images(new_images)

    videos = @phone.videos       if @phone
    videos = @defect.videos      if @defect
    videos = @generation.videos  if @generation
    videos = @repair.videos      if @repair
    videos = @model.videos       if @model
    videos = @mod.videos         if @mod
    videos = @spare_part.videos  if @spare_part
    videos = @makbook.videos     if @makbook
    videos = @imac.videos        if @imac
    videos = @ipad.videos        if @ipad
    videos = @airpod.videos      if @airpod
    videos = @apple_watch.videos if @apple_watch

    videos += new_videos

    @phone.videos = videos       if @phone.videos?
    @defect.videos = videos      if @defect.videos?
    @generation.videos = videos  if @generation.videos?
    @repair.videos = videos      if @repair.videos?
    @model.videos = videos       if @model.videos?
    @mod.videos = videos         if @mod.videos?
    @spare_part.videos = videos  if @spare_part.videos?
    @makbook.videos = videos     if @makbook.videos?
    @imac.videos = videos        if @imac.videos?
    @ipad.videos = videos        if @ipad.videos?
    @airpod.videos = videos      if @airpod.videos?
    @apple_watch.videos = videos if @apple_watch.videos?
  end

  def videos_params
    params.require(:phone).permit({ videos: [] })
    params.require(:defect).permit({ videos: [] })
    params.require(:generation).permit({ videos: [] })
    params.require(:repair).permit({ videos: [] })
    params.require(:model).permit({ videos: [] })
    params.require(:mod).permit({ videos: [] })
    params.require(:spare_part).permit({ videos: [] })
    params.require(:makbook).permit({ videos: [] })
    params.require(:imac).permit({ videos: [] })
    params.require(:ipad).permit({ videos: [] })
    params.require(:airpod).permit({ videos: [] })
    params.require(:apple_watch).permit({ videos: [] })
  end
end
