class Items::ArchivesController < ApplicationController
  def create
    @item = current_user.items.find(params[:item_id])
    @item.update!(status: :archived)
    current_user.update!(now_item: nil) if current_user.now_item == @item
  end
end
