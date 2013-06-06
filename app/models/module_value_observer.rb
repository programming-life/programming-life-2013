class ModuleValueObserver < ActiveRecord::Observer
	def after_update( value )
		value.module_instance.update_attribute(:updated_at, Time.now)
	end
end