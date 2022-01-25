class Post < ApplicationRecord
  belongs_to :user
  has_one_attached :feature_image


  #https://stackoverflow.com/questions/50640231/active-storage-with-amazon-s3-not-saving-with-filename-specified-but-using-file#:~:text=In%20order%20to%20have%20a%20custom%20filename%20on%20S3
  
  #def url()
  #  return "https://placehold.it/#{size}" unless feature_image.attached?
  #
  #  'https://my_s3_subdomain.amazonaws.com/' +
  #      feature_image.variant(resize: SIZES[size]).processed.key
  #end
end

