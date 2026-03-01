class ItemsController < ApplicationController
  def index
    @items = current_user.items
  end

  def new
    @item = current_user.items.build
  end

  def create
    @item = current_user.items.build(item_params)
    if @item.save
      redirect_to deck_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def item_params
    params.require(:item).permit(:title, :url, :memo, :action_type, :time_bucket, :energy)
  end
end
