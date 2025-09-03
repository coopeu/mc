# frozen_string_literal: true

class PlansController < ApplicationController
  before_action :set_plan, only: %i[show edit update destroy subscribe]
  before_action :authenticate_user!, only: %i[subscribe]

  # GET /plans or /plans.json
  def index
    @plans = Plan.all
  end

  # GET /plans/1 or /plans/1.json
  def show; end

  def subscribe
    price_id = @plan.sku.presence || @plan.codi.presence
    redirect_to plan_path(@plan), alert: 'Plan is missing Stripe price identifier.' and return if price_id.blank?

    customer = if current_user.stripe_customer_id.present?
                 current_user.stripe_customer_id
               else
                 stripe_customer = Stripe::Customer.create(email: current_user.email,
                                                           metadata: { user_id: current_user.id })
                 current_user.update!(stripe_customer_id: stripe_customer.id, stripe_email: stripe_customer.email)
                 stripe_customer.id
               end

    session = Stripe::Checkout::Session.create(
      mode: 'subscription',
      customer: customer,
      line_items: [{ price: price_id, quantity: 1 }],
      success_url: "#{plans_url}?subscribed=1",
      cancel_url: plan_url(@plan)
    )

    redirect_to session.url, allow_other_host: true
  rescue StandardError => e
    Rails.logger.error("Stripe subscribe error: #{e.message}")
    redirect_to plan_path(@plan), alert: 'Could not start subscription checkout.'
  end

  # GET /plans/new
  def new
    @plan = Plan.new
  end

  # GET /plans/1/edit
  def edit; end

  # POST /plans or /plans.json
  def create
    @plan = Plan.new(plan_params)

    respond_to do |format|
      if @plan.save
        format.html { redirect_to plan_url(@plan), notice: 'Plan was successfully created.' }
        format.json { render :show, status: :created, location: @plan }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plans/1 or /plans/1.json
  def update
    respond_to do |format|
      if @plan.update(plan_params)
        format.html { redirect_to plan_url(@plan), notice: 'Plan was successfully updated.' }
        format.json { render :show, status: :ok, location: @plan }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plans/1 or /plans/1.json
  def destroy
    @plan.destroy!

    respond_to do |format|
      format.html { redirect_to plans_url, notice: 'Plan was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_plan
    @plan = Plan.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def plan_params
    params.expect(plan: %i[product_id nom accesWeb maxSortidesAny preu descompteInscripcions
                           descompteBotiga detalls codi sku])
  end
end
