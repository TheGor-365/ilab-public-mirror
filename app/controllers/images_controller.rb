class ImagesController < ApplicationController

  before_action :set_phone
  before_action :set_defect
  before_action :set_generation
  before_action :set_repair
  before_action :set_model
  before_action :set_mod
  before_action :set_spare_part
  before_action :set_article
  before_action :set_post
  before_action :set_category
  before_action :set_chapter
  before_action :set_cource
  before_action :set_university


  def create
    add_more_images(images_params[:images])

    case toastr_flash[:error]
    when @phone
      toastr_flash[:error] = "Failed uploading images" unless @phone.save
    when @defect
      toastr_flash[:error] = "Failed uploading images" unless @defect.save
    when @generation
      toastr_flash[:error] = "Failed uploading images" unless @generation.save
    when @repair
      toastr_flash[:error] = "Failed uploading images" unless @repair.save
    when @model
      toastr_flash[:error] = "Failed uploading images" unless @model.save
    when @mod
      toastr_flash[:error] = "Failed uploading images" unless @mod.save
    when @spare_part
      toastr_flash[:error] = "Failed uploading images" unless @spare_part.save
    when @article
      toastr_flash[:error] = "Failed uploading images" unless @article.save
    when @post
      toastr_flash[:error] = "Failed uploading images" unless @post.save
    when @category
      toastr_flash[:error] = "Failed uploading images" unless @category.save
    when @chapter
      toastr_flash[:error] = "Failed uploading images" unless @chapter.save
    when @cource
      toastr_flash[:error] = "Failed uploading images" unless @cource.save
    when @university
      toastr_flash[:error] = "Failed uploading images" unless @university.save
    end

    redirect_to :back
  end


  def destroy
    remove_image_at_index(params[:id].to_i)

    case toastr_flash[:error]
    when @phone
      toastr_flash[:error] = "Failed deleting image" unless @phone.save
    when @defect
      toastr_flash[:error] = "Failed deleting image" unless @defect.save
    when @generation
      toastr_flash[:error] = "Failed deleting image" unless @generation.save
    when @repair
      toastr_flash[:error] = "Failed deleting image" unless @repair.save
    when @model
      toastr_flash[:error] = "Failed deleting image" unless @model.save
    when @mod
      toastr_flash[:error] = "Failed deleting image" unless @mod.save
    when @spare_part
      toastr_flash[:error] = "Failed deleting image" unless @spare_part.save
    when @article
      toastr_flash[:error] = "Failed deleting image" unless @article.save
    when @post
      toastr_flash[:error] = "Failed deleting image" unless @post.save
    when @category
      toastr_flash[:error] = "Failed deleting image" unless @category.save
    when @chapter
      toastr_flash[:error] = "Failed deleting image" unless @chapter.save
    when @cource
      toastr_flash[:error] = "Failed deleting image" unless @cource.save
    when @university
      toastr_flash[:error] = "Failed deleting image" unless @university.save
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

  def set_article
    @article = Article.find(params[:article_id])
  end

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_category
    @category = Category.find(params[:category_id])
  end

  def set_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end

  def set_cource
    @cource = Cource.find(params[:cource_id])
  end

  def set_university
    @university = University.find(params[:university_id])
  end


  def add_more_images(new_images)
    images = @phone.images if @phone
    images = @defect.images if @defect
    images = @generation.images if @generation
    images = @repair.images if @repair
    images = @model.images if @model
    images = @mod.images if @mod
    images = @spare_part.images if @spare_part
    images = @article.images if @article
    images = @post.images if @post
    images = @category.images if @category
    images = @chapter.images if @chapter
    images = @cource.images if @cource
    images = @university.images if @university

    images += new_images

    @phone.images = images if @phone.images?
    @defect.images = images if @defect.images?
    @generation.images = images if @generation.images?
    @repair.images = images if @repair.images?
    @model.images = images if @model.images?
    @mod.images = images if @mod.images?
    @spare_part.images = images if @spare_part.images?
    @article.images = images if @article.images?
    @post.images = images if @post.images?
    @category.images = images if @category.images?
    @chapter.images = images if @chapter.images?
    @cource.images = images if @cource.images?
    @university.images = images if @university.images?
  end
  

  def images_params
    params.require(:phone).permit({ images: [] })
    params.require(:defect).permit({ images: [] })
    params.require(:generation).permit({ images: [] })
    params.require(:repair).permit({ images: [] })
    params.require(:model).permit({ images: [] })
    params.require(:mod).permit({ images: [] })
    params.require(:spare_part).permit({ images: [] })
    params.require(:article).permit({ images: [] })
    params.require(:post).permit({ images: [] })
    params.require(:category).permit({ images: [] })
    params.require(:chapter).permit({ images: [] })
    params.require(:cource).permit({ images: [] })
    params.require(:university).permit({ images: [] })
  end

end
