module ApplicationHelper
	# Listifies a list
	#
	def listify( list )
		result = case list.count
			when 0 then 'none'
			when 1 then list.first
			else list.first( list.count - 1 ).join( ', ') + ' and ' + list.last
			end
		return result
	end
	
	def filter_on_key( results, key, value )
		return results.select { |result| result[key] == value }
	end
	
	def filter_on_key!( results, key, value )
		results = filter_on_key( results, key, value)
	end
	
	# This will create a link to the current document with the provided options
	# being added to the URL as query string parameters. You may either provide
	# the link text (the body) as the first parameter, or instead provide a block
	# that returns the content of the link. You may also provide a standard
	# html_options hash.
	#
	# In addition to adding any provided options as parameters to the query string
	# this will also add all query string parameters from the current request back
	# into the query string as well. To override an existing query string
	# parameter, simply provide an option of the same name (string or symbol form)
	# with the new value. If the new value is nil, the existing parameter will be
	# omitted. All non-string values will be converted using #to_s.
	#
	# Finally, you may provide an option with the key :fragment to specify a
	# fragment identifier you'd like to be appended onto the end of the URL. You
	# _must_ use the symbol :fragment, not the string "fragment" for the key,
	# otherwise the value will be added to the query string: "?fragment=value"
	#
	# == Signatures
	#
	#     link_to_self(body, options = {}, html_options = {})
	#       # body is the "name" (contents) of the link
	#
	#     link_to_self(options = {}, html_options = {}) do
	#       # link contents defined here
	#     end
	#
	def link_to_self(*args, &block)
		if block_given?
			options      = args.first || {}
			html_options = args.second
			link_to_self(capture(&block), options, html_options)
		else
			name         = args[0]
			options      = args[1] ? args[1].dup : {}
			html_options = args[2]
			fragment     = options.delete(:fragment)
			query_string = 
				options
				.with_indifferent_access
				.reverse_merge( request.query_parameters ).map { |k, v|
					v.nil? ? nil : "#{Rack::Utils.escape(k.to_s)}=#{Rack::Utils.escape(v.to_s)}"
				}.compact.join( "&" )
			path  = request.path
			path += "?#{query_string}" unless query_string.blank?
			path += "##{fragment}"     unless fragment.blank?
			result = link_to(name, path, html_options)
			result
		end
	end

end
