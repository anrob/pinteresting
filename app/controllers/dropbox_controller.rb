# -*- encoding : utf-8 -*-
require 'dropbox_sdk'

# This is an example of a Rails 3 controller that authorizes an application
# and then uploads a file to the user's Dropbox.

# You must set these
APP_KEY = "pzq83yj3n1jo7db"
APP_SECRET = "69c5l03tj7h2eig"
ACCESS_TYPE = :app_folder


# Examples routes for config/routes.rb  (Rails 3)
#match 'db/authorize', controller: 'db', action: 'authorize'
#match 'db/upload', controller: 'db', action: 'upload'

class DropboxController < ApplicationController
    def authorize
        if not params[:oauth_token] then
            dbsession = DropboxSession.new(APP_KEY, APP_SECRET)

            session[:dropbox_session] = dbsession.serialize #serialize and save this DropboxSession

            #pass to get_authorize_url a callback url that will return the user here
            redirect_to dbsession.get_authorize_url url_for(action: 'authorize')
        else
            # the user has returned from Dropbox
            dbsession = DropboxSession.deserialize(session[:dropbox_session])
            dbsession.get_access_token  #we've been authorized, so now request an access_token
            session[:dropbox_session] = dbsession.serialize

            redirect_to root_path
        end
    end

    def listpics
      dbsession = DropboxSession.deserialize(session[:dropbox_session])
      client = DropboxClient.new(dbsession, ACCESS_TYPE) #raise an exception if session not authorized
      @root_metadata = client.shares(dropbox)
      #self.root = 'sandbox' if client.access_type == 'app_folder' else 'dropbox'
      #@bo = client.session.root
    # @thepics = client.media(app_folder)
      #@root_metadata2 = @root_metadata.map { |k,v| }
      #puts "metadata:", @root_metadata.inspect
    end

    def upload
        # Check if user has no dropbox session...re-direct them to authorize
        return redirect_to(action: 'authorize') unless session[:dropbox_session]

        dbsession = DropboxSession.deserialize(session[:dropbox_session])
        client = DropboxClient.new(dbsession, ACCESS_TYPE) #raise an exception if session not authorized
        info = client.account_info # look up account information

        if request.method != "POST"
            # show a file upload page
            #render inline: #{}"#{info['email']} <br/><%= form_tag({action: :upload}, multipart: true) do %><%= file_field_tag 'file' %><%= submit_tag %><% end %>"
            return
        else
            # upload the posted file to dropbox keeping the same name
            resp = client.put_file(params[:file].original_filename, params[:file].read)
             flash[:notice] = "Upload successful! File now at #{resp['path']}"
        end
    end
end
