class VideosUploader < CarrierWave::Uploader::Base

  include CarrierWave::Video

  process encode_video: [:mp4, resolution: "640x480"]

  storage :file
  # storage :yandex_disk

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def full_filename(for_file)
    super.chomp(File.extname(super)) + '.mp4'
  end

  def filename
    original_filename.chomp(File.extname(original_filename)) + '.mp4'
  end

  version :thumb do
    process encode_video: [:mp4, resolution: "50x50"]
  end

  # def default_url(*args)
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # process scale: [200, 300]

  # def scale(width, height)
  #   # do something
  # end

  # def extension_allowlist
  #   %w(jpg jpeg gif png)
  # end

  # def filename
  #   "something.jpg" if original_filename
  # end
end
