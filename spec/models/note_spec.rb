require 'rails_helper'

RSpec.describe Note, type: :model do
  # メッセージがなければ無効な状態であること
  it "is invalid without a message" do
    note = Note.new(message: nil)
    note.valid?
    expect(note.errors[:message]).to include("can't be blank")
  end

  # 検索文字列に一致するメモを返すこと
  it 'returns notes that match the search term' do
    user = User.create(
      first_name: 'Joe',
      last_name:  'Tester',
      email:      'joetester@example.com',
      password:   'dottle-nouveau-pavillion-tights-furze'
    )

    project = user.projects.create(
      name: 'Test Project'
    )

    note1 = project.notes.create(
      message: 'This is the first note.',
      user: user
    )
    note2 = project.notes.create(
      message: 'This is the second note.',
      user: user
    )
    note3 = project.notes.create(
      message: 'First, preheat the oven.',
      user: user
    )

    expect(Note.search('first')).to include(note1, note3)
    expect(Note.search('first')).not_to include(note2)
  end

  # 検索結果が1件も見付からなければ空のコレクションを返すこと
  it 'returns an empty collection when no results are found' do
    user = User.create(
      first_name: 'Joe',
      last_name:  'Tester',
      email:      'joetester@example.com',
      password:   'dottle-nouveau-pavillion-tights-furze'
    )

    project = user.projects.create(
      name: 'Test Project'
    )

    note1 = project.notes.create(
      message: 'This is the first note.',
      user: user
    )
    note2 = project.notes.create(
      message: 'This is the second note.',
      user: user
    )
    note3 = project.notes.create(
      message: 'First, preheat the oven.',
      user: user
    )

    expect(Note.search('message')).to be_empty
  end
end
