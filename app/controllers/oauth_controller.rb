class OauthController < ApplicationController
  def callback
    # Todo: エンドポイントからのレスポンスは後から変更
    if params[:error].present?
      Rails.logger.error "OAuth error: #{params[:error]}"
      redirect_to root_path, alert: "連携に失敗しました (error: #{params[:error]})"
    elsif params[:code].present?
      Rails.logger.info "OAuth success: #{params[:code]}"
      redirect_to photos_path, notice: "連携に成功しました"
    end
  end
end
