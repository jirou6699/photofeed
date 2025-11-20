require "rails_helper"

RSpec.describe PhotosController, type: :request do
  describe "GET /index" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user, email: "other@example.com") }
    let!(:photo1) { create(:photo, user: user, title: "Old Photo", created_at: 2.days.ago) }
    let!(:photo2) { create(:photo, user: user, title: "New Photo", created_at: 1.day.ago) }
    let!(:other_photo) { create(:photo, user: other_user, title: "Other Photo") }

    context "ログインしている場合" do
      before do
        post sign_in_path, params: { email: user.email, password: user.password }
      end

      it "HTTPステータス200が返ること" do
        get photos_path
        expect(response).to have_http_status(:success)
      end

      it "ユーザーの写真一覧が表示されること" do
        get photos_path
        expect(response.body).to include("Old Photo")
        expect(response.body).to include("New Photo")
        expect(response.body).not_to include("Other Photo")
      end

      it "写真が作成日時の降順で表示されること" do
        get photos_path
        expect(response.body.index("New Photo")).to be < response.body.index("Old Photo")
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトすること" do
        get photos_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /new" do
    let(:user) { create(:user) }

    context "ログインしている場合" do
      before do
        post sign_in_path, params: { email: user.email, password: user.password }
      end

      it "HTTPステータス200が返ること" do
        get new_photo_path
        expect(response).to have_http_status(:success)
      end

      it "写真アップロードフォームが表示されること" do
        get new_photo_path
        expect(response.body).to include("title")
        expect(response.body).to include("thumbnail")
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトすること" do
        get new_photo_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /create" do
    let(:user) { create(:user) }
    let(:valid_params) do
      {
        photo: {
          title: "Test Photo",
          thumbnail: fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test.png'), 'image/png')
        }
      }
    end
    let(:invalid_params) do
      {
        photo: {
          title: "",
          thumbnail: nil
        }
      }
    end

    context "ログインしている場合" do
      before do
        post sign_in_path, params: { email: user.email, password: user.password }
      end

      context "有効なパラメータの場合" do
        it "photos_pathにリダイレクトすること" do
          post photos_path, params: valid_params
          expect(response).to redirect_to(photos_path)
        end

        it "成功メッセージが表示されること" do
          post photos_path, params: valid_params
          expect(flash[:notice]).to eq("写真をアップロードしました")
        end

        it "写真が作成されること" do
          expect {
            post photos_path, params: valid_params
          }.to change(Photo, :count).by(1)
        end

        it "作成された写真がログインユーザーに紐付くこと" do
          post photos_path, params: valid_params
          expect(Photo.last.user_id).to eq(user.id)
        end
      end

      context "無効なパラメータの場合" do
        it "HTTPステータス200が返ること" do
          post photos_path, params: invalid_params
          expect(response).to have_http_status(:success)
        end

        it "写真が作成されないこと" do
          expect {
            post photos_path, params: invalid_params
          }.not_to change(Photo, :count)
        end

        it "newテンプレートが表示されること" do
          post photos_path, params: invalid_params
          expect(response.body).to include("title")
        end
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトすること" do
        post photos_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end

      it "写真が作成されないこと" do
        expect {
          post photos_path, params: valid_params
        }.not_to change(Photo, :count)
      end
    end
  end

  describe "POST /tweet" do
    let(:user) { create(:user) }
    let(:photo) { create(:photo, user: user, title: "Tweet Photo") }
    let(:access_token) { "test_access_token" }

    context "ツイート作成に成功した場合" do
      let(:success_response) { double("response", code: "201") }
      let(:http) { double("http") }

      before do
        allow(Net::HTTP).to receive(:new).and_return(http)
        allow(http).to receive(:request).and_return(success_response)
      end

      it "photos_pathにリダイレクトすること" do
        post tweet_photo_path(photo)
        expect(response).to redirect_to(photos_path)
      end

      it "成功メッセージが表示されること" do
        post tweet_photo_path(photo)
        expect(flash[:notice]).to eq("ツイートを作成しました。")
      end
    end

    context "ツイート作成に失敗した場合" do
      let(:failure_response) { double("response", code: "400") }
      let(:http) { double("http") }

      before do
        allow(Net::HTTP).to receive(:new).and_return(http)
        allow(http).to receive(:request).and_return(failure_response)
      end

      it "photos_pathにリダイレクトすること" do
        post tweet_photo_path(photo)
        expect(response).to redirect_to(photos_path)
      end

      it "エラーメッセージが表示されること" do
        post tweet_photo_path(photo)
        expect(flash[:alert]).to eq("再度ツイートの作成をお願いします。")
      end
    end
  end
end
