require 'test_helper'

class StockScoresControllerTest < ActionController::TestCase
  setup do
    @stock_score = stock_scores(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stock_scores)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stock_score" do
    assert_difference('StockScore.count') do
      post :create, stock_score: { date: @stock_score.date, risk_funda_screen1_rank: @stock_score.risk_funda_screen1_rank, stock_id: @stock_score.stock_id }
    end

    assert_redirected_to stock_score_path(assigns(:stock_score))
  end

  test "should show stock_score" do
    get :show, id: @stock_score
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @stock_score
    assert_response :success
  end

  test "should update stock_score" do
    put :update, id: @stock_score, stock_score: { date: @stock_score.date, risk_funda_screen1_rank: @stock_score.risk_funda_screen1_rank, stock_id: @stock_score.stock_id }
    assert_redirected_to stock_score_path(assigns(:stock_score))
  end

  test "should destroy stock_score" do
    assert_difference('StockScore.count', -1) do
      delete :destroy, id: @stock_score
    end

    assert_redirected_to stock_scores_path
  end
end
