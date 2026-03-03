class TitlesController < ApplicationController
  def show
    title = Items::TitleFetcher.new(params[:url]).fetch
    render json: title.present? ? { title: title } : {}
  end
end
