ProgrammingLife::Application.routes.draw do

  resources :module_instances


  resources :module_templates


  resources :cells

  get "pdftest/test"

  post 'hook' => 'hook#post'
  get 'hook' => 'hook#index'
	
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'main#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
#== Route Map
# Generated on 06 May 2013 04:32
#
#     module_instances GET    /module_instances(.:format)          module_instances#index
#                      POST   /module_instances(.:format)          module_instances#create
#  new_module_instance GET    /module_instances/new(.:format)      module_instances#new
# edit_module_instance GET    /module_instances/:id/edit(.:format) module_instances#edit
#      module_instance GET    /module_instances/:id(.:format)      module_instances#show
#                      PUT    /module_instances/:id(.:format)      module_instances#update
#                      DELETE /module_instances/:id(.:format)      module_instances#destroy
#     module_templates GET    /module_templates(.:format)          module_templates#index
#                      POST   /module_templates(.:format)          module_templates#create
#  new_module_template GET    /module_templates/new(.:format)      module_templates#new
# edit_module_template GET    /module_templates/:id/edit(.:format) module_templates#edit
#      module_template GET    /module_templates/:id(.:format)      module_templates#show
#                      PUT    /module_templates/:id(.:format)      module_templates#update
#                      DELETE /module_templates/:id(.:format)      module_templates#destroy
#                cells GET    /cells(.:format)                     cells#index
#                      POST   /cells(.:format)                     cells#create
#             new_cell GET    /cells/new(.:format)                 cells#new
#            edit_cell GET    /cells/:id/edit(.:format)            cells#edit
#                 cell GET    /cells/:id(.:format)                 cells#show
#                      PUT    /cells/:id(.:format)                 cells#update
#                      DELETE /cells/:id(.:format)                 cells#destroy
#                 hook POST   /hook(.:format)                      hook#post
#                      GET    /hook(.:format)                      hook#index
#                 root        /                                    main#index
# 
# Routes for Teabag::Engine:
#      GET /fixtures/*filename(.:format) teabag/spec#fixtures
#      GET /:suite(.:format)             teabag/spec#runner {:suite=>"default"}
# root     /                             teabag/spec#suites
