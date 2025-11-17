class PhotosController < ApplicationController
  before_action :require_login, only: [ :index, :new, :create ]

  def index
    @photos = Photo.where(user_id: current_user.id).with_attached_thumbnail.order(created_at: :desc)
  end

  def new
    @photo = Photo.new
  end

  def create
    @photo = current_user.photos.new(photo_params)
    if @photo.save
      redirect_to photos_path, notice: '写真をアップロードしました'
    else
      render :new
    end
  rescue StandardError => e
    logger.error "Photo creation failed: #{e.message}"
    flash[:alert] = "please try again"
    render :new
  end

  private

  def photo_params
    params.require(:photo).permit(:title, :thumbnail)
  end
end
