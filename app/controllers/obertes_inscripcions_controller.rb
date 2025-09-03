# frozen_string_literal: true

class ObertesInscripcionsController < ApplicationController
  def index; end

  def create
    user = User.find(current_user.id)
    Inscripcio.all
    sortide = Sortide.find(params[:sortide_id])

    inscripcio = Inscripcio.new(user_id: user.id, sortide_id: sortide.id)
    inscripcio.save

    redirect_to sortide
  end
end
