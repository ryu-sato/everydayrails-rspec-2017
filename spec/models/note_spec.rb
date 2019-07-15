# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Note, type: :model do
  # ファクトリで関連するデータを生成する
  it 'generates associated data from a factory' do
    note = FactoryBot.create(:note)
    puts "This note's project is #{note.project.inspect}"
    puts "This note's user is #{note.user.inspect}"
  end

  # ユーザ、プロジェクト、メッセージがあれば有効な状態であること
  it 'is valid with a user, project, message' do
    project = FactoryBot.create(:project)
    note = Note.new(
      user: project.owner,
      project: project,
      message: 'This is a sample note.'
    )
    expect(note).to be_valid
  end

  # メッセージがなければ無効な状態であること
  it 'is invalid without a message' do
    note = Note.new(message: nil)
    note.valid?
    expect(note.errors[:message]).to include("can't be blank")
  end

  # 文字列に一致するメッセージを検索する
  describe 'search message for a term' do
    before do
      project = FactoryBot.create(:project)
      @note1 = project.notes.create(
        message: 'This is the first note.',
        user: project.owner
      )
      @note2 = project.notes.create(
        message: 'This is the second note.',
        user: project.owner
      )
      @note3 = project.notes.create(
        message: 'First, preheat the oven.',
        user: project.owner
      )
    end

    context 'when a match is found' do
      # 検索文字列に一致するメモを返すこと
      it 'returns notes that match the search term' do
        expect(Note.search('first')).to include(@note1, @note3)
        expect(Note.search('first')).not_to include(@note2)
      end
    end

    context 'when no match is found' do
      # 検索結果が1件も見付からなければ空のコレクションを返すこと
      it 'returns an empty collection when no results are found' do
        expect(Note.search('message')).to be_empty
      end
    end
  end
end
