require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  setup do
    @report = reports(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reports)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create report" do
    assert_difference('Report.count') do
      post :create, report: { cell_id: 3 }
    end

    assert_redirected_to report_path(assigns(:report)) 
  end

  test "should not create a duplicate report of a cell" do
    assert_no_difference('Report.count') do
      post :create, report: { cell_id: @report.cell_id }
    end

    #assert_redirected_to report_path(assigns(:report))
  end
  
  test "should get show" do
    get :show, id: @report
    assert_response :success
  end

  test "should destroy the report" do
    assert_difference('Report.count', -1) do
      delete :destroy, id: @report
    end

    assert_redirected_to reports_path
  end

end
