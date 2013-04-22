class Transporter extends Module

	constructor: ( params = {}, name, origin, destination ) ->
	
		# Step function for lipids
		step = ( t, substrates ) ->
		
			results = {}			
			return results
		
		# Default parameters set here
		defaults = { 
			name : name ? "#{origin}_to_#{destination}"
		}
		
		params = _( defaults ).extend( params )
		super params, step

(exports ? this).Transporter = Transporter