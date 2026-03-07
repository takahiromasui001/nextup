class ItemsController < ApplicationController
  before_action :set_item, only: [:edit, :update]

  def index
    status = params[:status].presence_in(Item.statuses.keys) || 'active'
    @status = status
    @items = current_user.items.where(status: status).order(updated_at: :desc)
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

  def edit; end

  def update
    if @item.update(item_params)
      redirect_to items_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_item
    @item = current_user.items.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:title, :url, :memo, :action_type, :time_bucket, :energy)
  end
end
