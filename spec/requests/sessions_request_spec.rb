require "rails_helper"

RSpec.describe SessionsController, type: :request do
  describe "GET /new" do
    it "HTTPステータス200が返ること" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "ログインページが表示されること" do
      get root_path
      expect(response.body).to include("email")
      expect(response.body).to include("password")
    end
  end

  describe "POST /create" do
    let(:user) { create(:user) }

    context "有効な認証情報の場合" do
      it "photos_pathにリダイレクトすること" do
        post sign_in_path, params: { email: user.email, password: user.password }
        expect(response).to redirect_to(photos_path)
      end

      it "成功メッセージが表示されること" do
        post sign_in_path, params: { email: user.email, password: user.password }
        expect(flash[:notice]).to eq("Logged in successfully")
      end

      it "セッションが作成されること" do
        post sign_in_path, params: { email: user.email, password: user.password }
        expect(session[:user_id]).to eq(user.id)
      end
    end

    context "無効な認証情報の場合" do
      it "HTTPステータス200が返ること" do
        post sign_in_path, params: { email: user.email, password: "wrong_password" }
        expect(response).to have_http_status(:success)
      end

      it "エラーメッセージが表示されること" do
        post sign_in_path, params: { email: user.email, password: "wrong_password" }
        expect(response.body).to include("emailかパスワードが正しくありません")
      end

      it "ログインフォームが再表示されること" do
        post sign_in_path, params: { email: user.email, password: "wrong_password" }
        expect(response.body).to include("email")
        expect(response.body).to include("password")
      end
    end

    context "バリデーションエラーの場合" do
      it "HTTPステータス200が返ること" do
        post sign_in_path, params: { email: "", password: "" }
        expect(response).to have_http_status(:success)
      end

      it "ログインフォームが再表示されること" do
        post sign_in_path, params: { email: "", password: "" }
        expect(response.body).to include("email")
        expect(response.body).to include("password")
      end
    end
  end

  describe "DELETE /destroy" do
    let(:user) { create(:user) }

    before do
      post sign_in_path, params: { email: user.email, password: user.password }
    end

    context "ログイン中の場合" do
      it "root_pathにリダイレクトすること" do
        delete sign_out_path
        expect(response).to redirect_to(root_path)
      end

      it "成功メッセージが表示されること" do
        delete sign_out_path
        expect(flash[:notice]).to eq("Logged out successfully")
      end

      it "user_idセッションが削除されること" do
        delete sign_out_path
        expect(session[:user_id]).to be_nil
      end
    end
  end
end
