require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  describe '#index' do
    # 認証済みのユーザとして
    context 'as an authenticated user' do
      before do
        @user = FactoryBot.create(:user)
      end

      # 正常にレスポンスを返すこと
      it 'responds successfully' do
        sign_in @user
        get :index
        expect(response).to be_success
      end

      # 200レスポンスを返すこと
      it 'returns a 200 response' do
        sign_in @user
        get :index
        expect(response).to have_http_status '200'
      end
    end
  end

  # ゲストとして
  context 'as a guest' do
    it 'returns a 302 response' do
      get :index
      expect(response).to have_http_status '302'
    end

    it 'redirects to the sign-in page' do
      get :index
      expect(response).to redirect_to '/users/sign_in'
    end
  end

  describe '#show' do
    # 認可されたユーザとして
    context 'as an authorized user' do
      before do
        @user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: @user)
      end

      # 正常にレスポンスを返すこと
      it 'responds successfully' do
        sign_in @user
        get :show, params: { id: @project.id }
        expect(response).to be_success
      end

      # 200レスポンスを返すこと
      it 'returns a 200 response' do
        sign_in @user
        get :show, params: { id: @project.id }
        expect(response).to have_http_status '200'
      end
    end
  end

  # 認可されていないユーザとして
  context 'as an unauthorized user' do
    before do
      @user = FactoryBot.create(:user)
      other_user = FactoryBot.create(:user)
      @project = FactoryBot.create(:project, owner: other_user)
    end

    it 'redirects to the dashboard' do
      sign_in @user
      get :show, params: { id: @project.id }
      expect(response).to redirect_to root_path
    end
  end
end
