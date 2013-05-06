module ApplicationHelper
	def listify( list )
		result = case list.count
			when 0 then 'none'
			when 1 then list.first
			else list.first( list.count - 1 ).join( ', ') + ' and ' + list.last
			end
		return result
	end
end
