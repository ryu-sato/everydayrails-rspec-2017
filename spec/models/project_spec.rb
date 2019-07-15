# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  before do
    @user = User.create(
      first_name: 'Joe',
      last_name: 'Tester',
      email: 'joetester@example.com',
      password: 'dottle-nouveau-pavillion-tights-furze'
    )
  end

  it 'is valid with name' do
    project = Project.new(
      owner: @user,
      name: 'test project'
    )
    expect(project).to be_valid
  end

  it 'is invalid without name' do
    project = Project.new(name: nil)
    expect(project).to_not be_valid
  end

  # ユーザ単位では重複したプロジェクトを許可しないこと
  it 'does not allow duplicate project names per user' do
    @user.projects.create(
      name: 'Test Project'
    )

    new_project = @user.projects.build(
      name: 'Test Project'
    )

    new_project.valid?
    expect(new_project.errors[:name]).to include('has already been taken')
  end

  # 二人のユーザーが同じ名前を使うことは許可すること
  it 'allows two users to share a project name' do
    @user.projects.create(
      name: 'Test Project'
    )

    other_user = User.create(
      first_name: 'Jane',
      last_name: 'Tester',
      email: 'testerb@example.com',
      password: 'dottle-nouveau-pavilion-tights-furze'
    )

    project = other_user.projects.build(
      name: 'Test Project'
    )

    expect(project).to be_valid
  end

  # 締め切り日が過ぎていれば遅延していること
  it 'is late when the due date is past today' do
    project = FactoryBot.create(:project_due_yesterday)
    expect(project).to be_late
  end

  # 締め切り日が今日ならスケジュールどおりであること
  it 'is on time when the due date is today' do
    project = FactoryBot.create(:project_due_today)
    expect(project).to_not be_late
  end

  # 締め切り日が明日ならスケジュールどおりであること
  it 'is on time when the due date is in the future' do
    project = FactoryBot.create(:project_due_tomorrow)
    expect(project).to_not be_late
  end
end
