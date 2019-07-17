require 'rails_helper'

RSpec.feature 'Projects', type: :feature do
  let(:user) { FactoryBot.create(:user) }
  let!(:project) do
    FactoryBot.create(:project,
                      name: 'RSpec tutorial',
                      owner: user)
  end

  # ユーザーは新しいプロジェクトを作成する
  scenario 'user creates a new project' do
    sign_in user
    go_to_root

    expect do
      click_link 'New Project'
      fill_in 'Name', with: 'Test Project'
      fill_in 'Description', with: 'Trying out Capybara'
      click_button 'Create Project'

      aggregate_failures do
        expect(page).to have_content 'Project was successfully created'
        expect(page).to have_content 'Test Project'
        expect(page).to have_content "Owner: #{user.name}"
      end
    end.to change(user.projects, :count).by(1)
  end

  # 認可のあるユーザーはプロジェクトを編集できる
  scenario 'user edit a own project' do
    sign_in user
    go_to_project project.name

    expect do
      click_link 'Edit'
      edit_project 'Test Project'

      aggregate_failures do
        expect(page).to have_content 'Project was successfully updated.'
        expect(page).to have_content 'Test Project'
        expect(page).to have_content "Owner: #{user.name}"
      end
    end
  end

  def go_to_root
    visit root_path
  end

  def go_to_project(name)
    visit root_path
    click_link name
  end

  def create_project(name = '', description = '')
    fill_project_form name, description
    click_button 'Create Project'
  end

  def edit_project(name = '', description = '')
    fill_project_form name, description
    click_button 'Update Project'
  end

  def fill_project_form(name = '', description = '')
    fill_in 'Name', with: name if name.present?
    fill_in 'Description', with: description if description.present?
  end
end
