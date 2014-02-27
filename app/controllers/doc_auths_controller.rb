class DocAuthsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  respond_to :html

  def index
    @doc_auths = DocAuth.all
  end

  def create
    @doc_auth = DocAuth.new params[:doc_auth]
    if @doc_auth.save
      flash[:notice] = 'Google spreadsheet was successfully added'
    end
    respond_with @doc_auth, location: doc_auths_path
  end

  def update
    if @doc_auth.update_attributes(params[:doc_auth])
      if @doc_auth.current?
        @doc_auth.set_as_current
      end
    end
    respond_with @doc_auth, location: doc_auths_path
  end

  def destroy
    @doc_auth.destroy
    respond_to @doc_auth
  end
end
