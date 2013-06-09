ProgrammingLife::Application.routes.draw do
	
	resources :reports
	resources :module_instances
	resources :module_templates
	resources :cells

	post 'hook' => 'hook#post'
	get 'hook' => 'hook#index'
	get 'version' => 'hook#version'
	
	unless Rails.env.production? or ( not Rails.application.config.assets.debug )
		offline = Rack::Offline.configure :cache_interval => 20 do      
		
			# Get everything from the css and js manifest
			manifests = ["application.css", "application.js"]
			files = manifests.map do |manifest|
				Rails.application.assets[manifest].dependencies.map{|d| "#{d.logical_path}"}
			end.flatten
			
			# Cache all these files
			files.each do |file|
				cache ActionController::Base.helpers.asset_path( file + '?body=1' )
			end
			
			# Cache the images we have in the public folder
			public = Rails.public_path
			public_path = Pathname.new( public )
			Dir[ public +  "/img/*.png", public +  "/img/*.jpg" , public +  "/img/*.gif"  ].each do |file|
				cache "/" + Pathname.new( file ).relative_path_from(public_path).to_s
			end
			# cache other assets
			network "/"  
		end
			
		# SWITCH IT BABE TO GET MANIFEST
		if true
			match "/gigabase.manifest" => offline
		end
	else
		offline = Rack::Offline.configure :cache_interval => 120 do      
		
			# Get everything from the css and js manifest, combined in 2 files
			cache ActionController::Base.helpers.asset_path("application.css")
			cache ActionController::Base.helpers.asset_path("application.js")
			
			# Cache the images we have in the public folder
			public = Rails.public_path
			public_path = Pathname.new( public )
			Dir[ public + "/img/*.png", public +  "/img/*.jpg" , public +  "/img/*.gif"  ].each do |file|
				cache "/" + Pathname.new( file ).relative_path_from(public_path).to_s
			end
			# cache other assets
			network "/"  
		end
			
		match "/gigabase.manifest" => offline
	end
	
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
# Generated on 11 May 2013 04:35
#
#              reports GET    /reports(.:format)                   reports#index
#                      POST   /reports(.:format)                   reports#create
#           new_report GET    /reports/new(.:format)               reports#new
#          edit_report GET    /reports/:id/edit(.:format)          reports#edit
#               report GET    /reports/:id(.:format)               reports#show
#                      PUT    /reports/:id(.:format)               reports#update
#                      DELETE /reports/:id(.:format)               reports#destroy
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
