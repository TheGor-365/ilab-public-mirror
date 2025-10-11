module ApplicationHelper
  def toastr_flash
    flash.each_with_object([]) do |(type, message), flash_messages|
      type = 'success' if type == 'notice'
      type = 'error'   if type == 'alert'
      text = "<script>toastr.#{type}('#{message}', '', { closeButton: true, progressBar: true })</script>"
      flash_messages << text.html_safe if message
    end.join("\n").html_safe
  end

  def user_avatar(user, width)
    image_path = user.avatar.present? ? user.avatar.url : 'default_avatar.jpg'
    image_tag(image_path, width: width, height: width, class: 'rounded shadow-sm')
  end

  def images_middle(phones, width)
    images_urls = phones.images.present? ? phones.images_urls : 'default_avatar.jpg'
    images_urls.each do |image|
      image_tag(image, width: '300', height: width, class: 'rounded')
    end
  end

  def current_order
    if Order.find_by_id(session[:order_id]).nil?
      Order.new
    else
      Order.find_by_id(session[:order_id])
    end
  end

  def full_title(page_title = "")
    base_title = "iLab"
    if page_title.present?
      "#{base_title} | #{page_title}"
    else
      base_title
    end
  end

  # теперь только запоминаем «текущую вкладку», без рендера
  def currently_at(current_page = "")
    @current_page_title = current_page
    nil
  end

  # Подсветка активного пункта
  def nav_tab(title, url, options = {})
    local_current_page = options.delete(:current_page)

    is_active =
      (local_current_page.present? && local_current_page == title) ||
      current_page?(url) ||
      (url.present? && url != '/' && request.path.start_with?(url))

    base_class = is_active ? 'text-white bg-dark rounded active' : nil
    options[:class] = [options[:class], 'nav-link', base_class].compact.join(' ')
    options['aria-current'] = 'page' if is_active

    link_to title, url, options
  end
end
