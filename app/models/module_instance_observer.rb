class ModuleInstanceObserver < ActiveRecord::Observer
	def after_create( instance )
		instance.cell.update_attribute(:updated_at, Time.now)
	end

	def after_update( instance )
		instance.cell.update_attribute(:updated_at, Time.now)
	end

	def after_destroy( instance )
		instance.cell.update_attribute(:updated_at, Time.now)
	end
end