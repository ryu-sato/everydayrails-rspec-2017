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

  describe '#create' do
    # 認証済みのユーザとして
    context 'as an authorized user' do
      before do
        @user = FactoryBot.create(:user)
      end

      # 有効な属性値の場合
      context 'with valid attributes' do
        # プロジェクトを追加できること
        it 'adds a project' do
          project_params = FactoryBot.attributes_for(:project)
          sign_in @user
          expect do
            post :create, params: { project: project_params }
          end.to change(@user.projects, :count).by(1)
        end
      end

      context 'with invalid attributes' do
        # プロジェクトを追加できないこと
        it 'does not add a project' do
          project_params = FactoryBot.attributes_for(:project, :invalid)
          sign_in @user
          expect do
            post :create, params: { project: project_params }
          end.to_not change(@user.projects, :count)
        end
      end
    end

    # ゲストとして
    context 'as a guest' do
      # 302レスポンスを返すこと
      it 'returns a 302 response' do
        project_params = FactoryBot.attributes_for(:project)
        post :create, params: { project: project_params }
        expect(response).to have_http_status '302'
      end

      # サインイン画面にリダイレクトされること
      it 'redirects to the sign-in page' do
        project_params = FactoryBot.attributes_for(:project)
        post :create, params: { project: project_params }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe '#update' do
    # 認証済みのユーザとして
    context 'as an authorized user' do
      before do
        @user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: @user)
      end

      # プロジェクトを更新できること
      it 'updates a project' do
        project_params = FactoryBot.attributes_for(
          :project,
          name: 'New Project Name'
        )
        sign_in @user
        patch :update, params: { id: @project.id, project: project_params }
        expect(@project.reload.name).to eq 'New Project Name'
      end
    end

    # 認可されていないユーザとして
    context 'as an anauthorized user' do
      before do
        @user = FactoryBot.create(:user)
        other_user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project,
                                     owner: other_user,
                                     name: 'Same Old Name')
      end

      # プロジェクトを更新できないこと
      it 'does not update the project' do
        project_params = FactoryBot.attributes_for(
          :project,
          name: 'New Project Name'
        )
        sign_in @user
        patch :update, params: { id: @project.id, project: project_params }
        expect(@project.reload.name).to eq 'Same Old Name'
      end

      # ダッシュボードへリダイレクトされること
      it 'redirects to the dashboard' do
        project_params = FactoryBot.attributes_for(:project)
        sign_in @user
        patch :update, params: { id: @project.id, project: project_params }
        expect(@project.reload.name).to redirect_to root_path
      end
    end

    # ゲストとして
    context 'as an guest' do
      # 302レスポンスを返すこと
      it 'returns a 302 response' do
        project_params = FactoryBot.attributes_for(:project)
        post :create, params: { project: project_params }
        expect(response).to have_http_status '302'
      end

      # サインイン画面にリダイレクトされること
      it 'redirects to the sign-in page' do
        project_params = FactoryBot.attributes_for(:project)
        post :create, params: { project: project_params }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe '#destroy' do
    # 認証済みのユーザとして
    context 'as an authorized user' do
      before do
        @user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: @user)
      end

      # プロジェクトを削除できること
      it 'updates a project' do
        sign_in @user
        expect do
          delete :destroy, params: { id: @project.id }
        end.to change(@user.projects, :count).by(-1)
      end
    end

    # 認可されていないユーザとして
    context 'as an anauthorized user' do
      before do
        @user = FactoryBot.create(:user)
        other_user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: other_user)
      end

      # プロジェクトを削除できないこと
      it 'does not update the project' do
        sign_in @user
        expect do
          delete :destroy, params: { id: @project.id }
        end.to_not change(@user.projects, :count)
      end

      # ダッシュボードへリダイレクトされること
      it 'redirects to the dashboard' do
        sign_in @user
        delete :destroy, params: { id: @project.id }
        expect(@project.reload.name).to redirect_to root_path
      end
    end

    # ゲストとして
    context 'as an guest' do
      before do
        @project = FactoryBot.create(:project)
      end

      # 302レスポンスを返すこと
      it 'returns a 302 response' do
        delete :destroy, params: { id: @project.id }
        expect(response).to have_http_status '302'
      end

      # サインイン画面にリダイレクトされること
      it 'redirects to the sign-in page' do
        delete :destroy, params: { id: @project.id }
        expect(response).to redirect_to '/users/sign_in'
      end

      # プロジェクトを削除できないこと
      it 'does not update the project' do
        expect do
          delete :destroy, params: { id: @project.id }
        end.to_not change(Project, :count)
      end
    end
  end
end
