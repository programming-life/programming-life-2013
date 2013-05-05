require 'test_helper'

class ModuleTemplatesControllerTest < ActionController::TestCase
  setup do
    @module_template = module_templates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:module_templates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create module_template" do
    assert_difference('ModuleTemplate.count') do
      post :create, module_template: {  }
    end

    assert_redirected_to module_template_path(assigns(:module_template))
  end

  test "should show module_template" do
    get :show, id: @module_template
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @module_template
    assert_response :success
  end

  test "should update module_template" do
    put :update, id: @module_template, module_template: {  }
    assert_redirected_to module_template_path(assigns(:module_template))
  end

  test "should destroy module_template" do
    assert_difference('ModuleTemplate.count', -1) do
      delete :destroy, id: @module_template
    end

    assert_redirected_to module_templates_path
  end
end
