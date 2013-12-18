require 'test_helper'

class ReposControllerTest < ActionController::TestCase
  setup do
    @repo = repos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:repos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create repo" do
    assert_difference('Repo.count') do
      post :create, repo: { date_created: @repo.date_created, date_pushed: @repo.date_pushed, date_update: @repo.date_update, fork: @repo.fork, full_name: @repo.full_name, git_id: @repo.git_id, name: @repo.name }
    end

    assert_redirected_to repo_path(assigns(:repo))
  end

  test "should show repo" do
    get :show, id: @repo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @repo
    assert_response :success
  end

  test "should update repo" do
    patch :update, id: @repo, repo: { date_created: @repo.date_created, date_pushed: @repo.date_pushed, date_update: @repo.date_update, fork: @repo.fork, full_name: @repo.full_name, git_id: @repo.git_id, name: @repo.name }
    assert_redirected_to repo_path(assigns(:repo))
  end

  test "should destroy repo" do
    assert_difference('Repo.count', -1) do
      delete :destroy, id: @repo
    end

    assert_redirected_to repos_path
  end
end
