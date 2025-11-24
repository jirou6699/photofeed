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
      redirect_to photos_path, notice: t('flash.photos.upload_success')
    else
      flash.now[:alert] = t('flash.photos.upload_error')
      render :new
    end
  end

  def tweet
    photo = Photo.find(params[:id])
    title = photo.title
    image_url = url_for(photo.thumbnail)
    access_token = session[:oauth_access_token]
    uri = URI(ENV['TWEET_API_URL'])

    request = build_tweet_request(uri, title, image_url, access_token)
    response = post_tweet(uri, request)

    if response.code.to_i == 201
      redirect_to photos_path, notice: t('flash.photos.tweet_success')
    else
      redirect_to photos_path, alert: t('flash.photos.tweet_error')
    end
  rescue StandardError => e
    logger.error "Tweet creation failed: #{e.message}"
    redirect_to photos_path, alert: t('flash.photos.tweet_exception')
  end

  private

  def photo_params
    params.require(:photo).permit(:title, :thumbnail)
  end

  def build_tweet_request(uri, title, image_url, access_token)
    request = Net::HTTP::Post.new(uri.path, {
      'Content-Type'  => 'application/json',
      'Authorization' => "Bearer #{access_token}"
    })

    request.body = {
      text: title,
      url:  image_url
    }.to_json

    request
  end

  def post_tweet(uri, request)
    http = Net::HTTP.new(uri.host, uri.port)
    http.request(request)
  end
end
