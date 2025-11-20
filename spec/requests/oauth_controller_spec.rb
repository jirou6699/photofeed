require "rails_helper"

RSpec.describe OauthController, type: :request do
  describe "GET /callback" do
    let(:code) { "test_authorization_code" }
    let(:access_token) { "test_access_token" }
    let(:success_response_body) { { access_token: access_token }.to_json }

    context "認証コードが存在し、トークン取得に成功した場合" do
      let(:success_response) { double("response", body: success_response_body) }

      before do
        allow(Net::HTTP).to receive(:post_form).and_return(success_response)
        allow(success_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
      end

      it "photos_pathにリダイレクトすること" do
        get oauth_callback_path, params: { code: code }
        expect(response).to redirect_to(photos_path)
      end

      it "成功メッセージが表示されること" do
        get oauth_callback_path, params: { code: code }
        expect(flash[:notice]).to eq("連携が完了しました")
      end

      it "アクセストークンがセッションに保存されること" do
        get oauth_callback_path, params: { code: code }
        expect(session[:oauth_access_token]).to eq(access_token)
      end
    end

    context "認証コードが存在しない場合" do
      it "photos_pathにリダイレクトすること" do
        get oauth_callback_path, params: { code: "" }
        expect(response).to redirect_to(photos_path)
      end

      it "エラーメッセージが表示されること" do
        get oauth_callback_path, params: { code: "" }
        expect(flash[:alert]).to eq("再度連携をお願いします")
      end
    end

    context "トークン取得に失敗した場合" do
      let(:failure_response) { double("response", body: "Bad Request") }

      before do
        allow(Net::HTTP).to receive(:post_form).and_return(failure_response)
        allow(failure_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)
      end

      it "photos_pathにリダイレクトすること" do
        get oauth_callback_path, params: { code: code }
        expect(response).to redirect_to(photos_path)
      end

      it "エラーメッセージが表示されること" do
        get oauth_callback_path, params: { code: code }
        expect(flash[:alert]).to eq("再度連携をお願いします")
      end
    end

    context "アクセストークンがレスポンスに含まれていない場合" do
      let(:empty_response) { double("response", body: {}.to_json) }

      before do
        allow(Net::HTTP).to receive(:post_form).and_return(empty_response)
        allow(empty_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
      end

      it "photos_pathにリダイレクトすること" do
        get oauth_callback_path, params: { code: code }
        expect(response).to redirect_to(photos_path)
      end

      it "エラーメッセージが表示されること" do
        get oauth_callback_path, params: { code: code }
        expect(flash[:alert]).to eq("再度連携をお願いします")
      end
    end

    context "例外が発生した場合" do
      before do
        allow(Net::HTTP).to receive(:post_form).and_raise(StandardError.new("Network error"))
      end

      it "photos_pathにリダイレクトすること" do
        get oauth_callback_path, params: { code: code }
        expect(response).to redirect_to(photos_path)
      end

      it "エラーメッセージが表示されること" do
        get oauth_callback_path, params: { code: code }
        expect(flash[:alert]).to eq("再度連携をお願いします")
      end
    end
  end
end
