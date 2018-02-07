require 'test_helper'

class MemosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @memo = memos(:one)
  end

  test "should get index" do
    get memos_url
    assert_response :success
  end

  test "should get new" do
    get new_memo_url
    assert_response :success
  end

  test "should create memo" do
    assert_difference('Memo.count') do
      post memos_url, params: { memo: { content: @memo.content, title: @memo.title, user_id: @memo.user_id } }
    end

    assert_redirected_to memo_url(Memo.last)
  end

  test "should show memo" do
    get memo_url(@memo)
    assert_response :success
  end

  test "should get edit" do
    get edit_memo_url(@memo)
    assert_response :success
  end

  test "should update memo" do
    patch memo_url(@memo), params: { memo: { content: @memo.content, title: @memo.title, user_id: @memo.user_id } }
    assert_redirected_to memo_url(@memo)
  end

  test "should destroy memo" do
    assert_difference('Memo.count', -1) do
      delete memo_url(@memo)
    end

    assert_redirected_to memos_url
  end
end
