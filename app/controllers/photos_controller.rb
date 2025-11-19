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
    flash[:alert] = 'please try again'
    render :new
  end

  def tweet
    photo = Photo.find(params[:id])
    title = photo.title
    image_url = url_for(photo.thumbnail)
    access_token = session[:oauth_access_token]

    request = build_tweet_request(title, image_url, access_token)
    response = post_tweet(request)

    if response.code.to_i == 201
      redirect_to photos_path, notice: 'ツイートを作成しました。'
    else
      redirect_to photos_path, alert: '再度ツイートの作成をお願いします。'
    end
  rescue StandardError => e
    logger.error "Tweet creation failed: #{e.message}"
    redirect_to photos_path, alert: 'ツイートの作成中にエラーが発生しました。'
  end

  private

  def photo_params
    params.require(:photo).permit(:title, :thumbnail)
  end

  def build_tweet_request(title, image_url, access_token)
    uri = URI(ENV['TWEET_API_URL'])
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

  def post_tweet(request)
    uri = URI(ENV['TWEET_API_URL'])
    http = Net::HTTP.new(uri.host, uri.port)
    http.request(request)
  end
end
