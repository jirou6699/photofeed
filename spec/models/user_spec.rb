require "rails_helper"

RSpec.describe User, type: :model do
  describe "#find_for_authentication_with" do
    let(:password) { "password" }
    let!(:user) { create(:user) }

    context "正しいemailとpasswordが与えられた場合" do
      it "ユーザーを返すこと" do
        params = { email: user.email, password: password }
        result = User.find_for_authentication_with(params)
        expect(result).to eq(user)
      end
    end

    context "passwordが間違っている場合" do
      it "nilを返すこと" do
        params = { email: user.email, password: "wrongpassword" }
        result = User.find_for_authentication_with(params)
        expect(result).to be_nil
      end
    end

    context "emailが存在しない場合" do
      it "nilを返すこと" do
        params = { email: "nonexistent@example.com", password: password }
        result = User.find_for_authentication_with(params)
        expect(result).to be_nil
      end
    end

    context "emailがnilの場合" do
      it "nilを返すこと" do
        params = { email: nil, password: password }
        result = User.find_for_authentication_with(params)
        expect(result).to be_nil
      end
    end

    context "passwordがnilの場合" do
      it "nilを返すこと" do
        params = { email: user.email, password: nil }
        result = User.find_for_authentication_with(params)
        expect(result).to be_nil
      end
    end

    context "両方のparamsがnilの場合" do
      it "nilを返すこと" do
        params = { email: nil, password: nil }
        result = User.find_for_authentication_with(params)
        expect(result).to be_nil
      end
    end
  end

  describe "#normalize_email" do
    it "emailを小文字に変換すること" do
      params = { email: "USER@EXAMPLE.COM" }
      normalized_email = User.normalize_email(params)
      expect(normalized_email).to eq("user@example.com")
    end
  end

  describe "#session_token" do
    let(:user) { create(:user) }

    context "session_tokenが存在しない場合" do
      it "session_tokenを生成すること" do
        expect(SecureRandom).to receive(:urlsafe_base64).and_call_original
        expect(user.session_token).to be_present
      end
    end

    context "session_tokenが既に存在する場合" do
      it "既存のトークンを返すこと" do
        first_token = user.session_token
        expect(SecureRandom).not_to receive(:urlsafe_base64)
      end
    end
  end

  describe "#update_session_digest!" do
    let(:user) { create(:user) }

    it "update!処理が完了すること" do
      session_token = user.session_token
      user.update_session_digest!
      expect(user.reload.session_digest).to be_present
      expect(BCrypt::Password.new(user.session_digest).is_password?(session_token)).to be true
    end
  end

  describe "#authenticated?" do
    let(:user) { create(:user) }
    let(:token) { "test_token" }

    before do
      user.update!(session_digest: BCrypt::Password.create(token))
    end

    context "正しいトークンが与えられた場合" do
      it "trueを返すこと" do
        expect(user.authenticated?(token)).to be true
      end
    end

    context "間違ったトークンが与えられた場合" do
      it "falseを返すこと" do
        expect(user.authenticated?("wrong_token")).to be false
      end
    end
  end

  describe "#delete_session_digest!" do
    let(:user) { create(:user) }

    it "update!でsession_digestカラムが空になること" do
      user.update!(session_digest: "some_digest")

      expect { user.delete_session_digest! }.to change { user.reload.session_digest }.to(nil)
    end
  end
end
