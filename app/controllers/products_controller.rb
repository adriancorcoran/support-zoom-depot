# frozen_string_literal: true
class ProductsController < ApplicationController
  include CurrentCart
  before_action :set_cart
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
    @products = Product.all.order(:title)
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: I18n.t('messages.product.created') }
        format.json { render :show, status: :created, location: @product }
      else
        puts @product.errors.full_messages
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: I18n.t('messages.product.updated') }
        format.json { render :show, status: :ok, location: @product }

        # broadcast update info
        @products = Product.all.order(:title)
        ActionCable.server.broadcast('products_channel', html: render_to_string('store/index', layout: false))
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    respond_to do |format|
      if @product.destroy
        format.html { redirect_to products_url, notice: I18n.t('messages.product.destroyed') }
        format.json { head :no_content }
      else
        format.html do
          flash[:error] = I18n.t('messages.product.not_destroyed')
          redirect_to @product
        end
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /who_bought/1
  # GET /who_bought/1.json
  def who_bought
    @product = Product.find_by(id: params[:id])
    @orders = @product.orders.order(id: :desc)
    # don't want any caching in our API, instead of stale, we will rate limit our fictional api users
    respond_to do |format|
      format.json
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def product_params
    params.require(:product).permit(:title, :description, :image_url, :price)
  end
end
