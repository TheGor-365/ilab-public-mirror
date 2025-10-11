class AvatarUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  storage :file
  # storage :yandex_disk

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :thumb do
    process resize_to_fit: [200, 160]
  end

  def extension_allowlist
    %w(jpg jpeg png)
  end

  # def default_url(*args)
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # process scale: [200, 300]

  # def scale(width, height)
  #   # do something
  # end

  # def filename
  #   "something.jpg" if original_filename
  # end
end
