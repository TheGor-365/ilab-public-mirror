class Profile

  mount_uploader  :avatar, AvatarUploader
  mount_uploaders :images, ImageUploader
  mount_uploaders :videos, VideosUploader

  belongs_to :user

end
