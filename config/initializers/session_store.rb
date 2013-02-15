# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_life_session',
  :secret      => '3767dcb4111890dcb00d4b350f41b08ae7b7a101da36a8faa1d5a8804e1ac6c5f8c3f1d370f173b8677093b9a5c63a5255ef266e94261a699df5409b02537595'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
