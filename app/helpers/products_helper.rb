module ProductsHelper

  def product_avatar product, width, height
    avatar_path = product.avatar.present? ? product.avatar.url : 'default_product_avatar.jpg'
    image_tag(avatar_path, width: width, height: height, class: 'rounded')
  end

end
