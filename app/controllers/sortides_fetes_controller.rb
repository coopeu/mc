# frozen_string_literal: true

class SortidesFetesController < ApplicationController
  def index
    Time.zone.current
    @sortides_fetes = SortidesFete.order(start_date: :asc)
    @sortides = Sortide.order(start_date: :asc)
  end

  def new
    @sortides_fete = SortidesFete.new
  end

  def edit
    @sortides_fete = SortidesFete.find(params[:id])
  end

  def create
    @sortides_fete = SortidesFete.new(sortides_fete_params)
    if @sortides_fete.save
      redirect_to sortides_fetes_path, notice: 'Sortida created successfully.'
    else
      render :new
    end
  end

  def update
    @sortides_fete = SortidesFete.find(params[:id])
    if @sortides_fete.update(sortides_fete_params)
      redirect_to sortides_fetes_path, notice: 'Sortida updated successfully.'
    else
      render :edit
    end
  end

  private

  def sortides_fete_params
    params.expect(sortides_fete: %i[title start_date youtube_link])
  end
end
