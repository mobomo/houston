class RawItemsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  respond_to :html

  def index
    @raw_items = RawItem.all
  end

  def destroy
    @raw_item.destroy
    redirect_to raw_items_url, notice: 'Raw Item has been destroyed'
  end

end
