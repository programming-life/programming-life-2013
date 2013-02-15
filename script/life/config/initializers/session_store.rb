# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_life_session',
  :secret      => '49078ba0a738961eb008666737dec750c146243b9116fdfc319cb0b60d46283e11339b4c25cc16bd653c22d0a722ab7838253828f90a1790f0cf3fbd77f59e9a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
