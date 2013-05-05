require 'test_helper'

class ModuleInstancesControllerTest < ActionController::TestCase
  setup do
    @module_instance = module_instances(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:module_instances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create module_instance" do
    assert_difference('ModuleInstance.count') do
      post :create, module_instance: {  }
    end

    assert_redirected_to module_instance_path(assigns(:module_instance))
  end

  test "should show module_instance" do
    get :show, id: @module_instance
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @module_instance
    assert_response :success
  end

  test "should update module_instance" do
    put :update, id: @module_instance, module_instance: {  }
    assert_redirected_to module_instance_path(assigns(:module_instance))
  end

  test "should destroy module_instance" do
    assert_difference('ModuleInstance.count', -1) do
      delete :destroy, id: @module_instance
    end

    assert_redirected_to module_instances_path
  end
end
