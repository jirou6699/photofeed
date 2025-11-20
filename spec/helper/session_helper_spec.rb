require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do
  describe '#sign_in' do
    let(:user) { create(:user) }

    context '有効なユーザーを渡した場合' do
      it 'session[:user_id]にユーザーIDが設定される' do
        helper.sign_in(user)
        expect(session[:user_id]).to eq(user.id)
      end
    end

    context '異なるユーザーでサインインした場合' do
      let(:another_user) { create(:user, email: 'another@example.com') }

      it 'session[:user_id]が新しいユーザーIDに上書きされる' do
        helper.sign_in(user)
        expect(session[:user_id]).to eq(user.id)

        helper.sign_in(another_user)
        expect(session[:user_id]).to eq(another_user.id)
      end
    end
  end

  describe '#persist_session_for' do
    let(:user) { create(:user) }

    context '有効なユーザーを渡した場合' do
      before do
        allow(user).to receive(:update_session_digest!)
      end

      it 'cookies.permanent.encrypted[:user_id]にユーザーIDが設定される' do
        helper.persist_session_for(user)
        expect(cookies.permanent.encrypted[:user_id]).to eq(user.id)
      end

      it 'cookies.permanent[:session_token]にユーザーのセッショントークンが設定される' do
        helper.persist_session_for(user)
        expect(cookies.permanent[:session_token]).to eq(user.session_token)
      end
    end
  end

  describe '#remove_persistent_session' do
    let(:user) { create(:user) }

    context '有効なユーザーを渡した場合' do
      before do
        allow(user).to receive(:delete_session_digest!)
        cookies[:user_id] = user.id
        cookies[:session_token] = 'test_token'
      end

      it 'cookies[:user_id]が削除される' do
        helper.remove_persistent_session(user)
        expect(cookies[:user_id]).to be_nil
      end

      it 'cookies[:session_token]が削除される' do
        helper.remove_persistent_session(user)
        expect(cookies[:session_token]).to be_nil
      end
    end
  end

  describe '#logged_in?' do
    context 'ユーザーがログインしている場合' do
      before do
        allow(helper).to receive(:current_user).and_return(double('User'))
      end

      it 'trueを返す' do
        expect(helper.logged_in?).to be true
      end
    end

    context 'ユーザーがログインしていない場合' do
      before do
        allow(helper).to receive(:current_user).and_return(nil)
      end

      it 'falseを返す' do
        expect(helper.logged_in?).to be false
      end
    end
  end

  describe '#current_user' do
    context 'current_userがすでに設定されている場合' do
      let(:user) { create(:user) }

      before do
        helper.instance_variable_set(:@current_user, user)
      end

      it 'current_userを返すこと' do
        expect(helper).not_to receive(:find_user_from_cookies)
        expect(helper.current_user).to eq(user)
      end
    end
  end

  describe '#sign_out' do
    context 'ユーザーがログインしている場合' do
      let(:user) { create(:user) }

      before do
        allow(helper).to receive(:logged_in?).and_return(true)
        allow(helper).to receive(:current_user).and_return(user)
        session[:user_id] = user.id
        helper.instance_variable_set(:@current_user, user)
      end

      it 'remove_persistent_sessionが呼ばれる' do
        expect(helper).to receive(:remove_persistent_session).with(user)
        helper.sign_out
      end

      it 'session[:user_id]が削除される' do
        allow(helper).to receive(:remove_persistent_session)
        helper.sign_out
        expect(session[:user_id]).to be_nil
      end

      it '@current_userがnilになる' do
        allow(helper).to receive(:remove_persistent_session)
        helper.sign_out
        expect(helper.instance_variable_get(:@current_user)).to be_nil
      end
    end

    context 'ユーザーがログインしていない場合' do
      before do
        allow(helper).to receive(:logged_in?).and_return(false)
        session[:user_id] = 123
      end

      it 'remove_persistent_sessionが呼ばれない' do
        expect(helper).not_to receive(:remove_persistent_session)
        helper.sign_out
      end
    end
  end
end
