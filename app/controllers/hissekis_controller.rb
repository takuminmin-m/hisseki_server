class HissekisController < ApplicationController
  before_action :set_hisseki, only: :destroy

  # GET /hissekis or /hissekis.json
  def index
    @hissekis = Hisseki.all
  end

  # GET /hissekis/1 or /hissekis/1.json
  #def show; end

  # GET /hissekis/new
  def new
    @hisseki = Hisseki.new
  end

  # GET /hissekis/1/edit
  #def edit; end

  # POST /hissekis or /hissekis.json
  def create
    @hisseki = Hisseki.new(hisseki_params)
    puts request.body

    @json_return = if @hisseki.save
      # js側でリダイレクトさせる
      {url: hissekis_url}
    else
      # js側でエラーメッセージを表示
      {message: @hisseki.errors.map{ |error| error.full_message }.join("\n")}
    end

    render json: @json_return
    LearnHissekiJob.perform_later
  end

  # PATCH/PUT /hissekis/1 or /hissekis/1.json
  #def update
  #  respond_to do |format|
  #    if @hisseki.update(hisseki_params)
  #      format.html { redirect_to @hisseki, notice: "Hisseki was successfully updated." }
  #      format.json { render :show, status: :ok, location: @hisseki }
  #    else
  #      format.html { render :edit, status: :unprocessable_entity }
  #      format.json { render json: @hisseki.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  # DELETE /hissekis/1 or /hissekis/1.json
  # def destroy
  #   @hisseki.destroy
  #   respond_to do |format|
  #     format.html { redirect_to hissekis_url, notice: "Hisseki was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  # def show_hisseki
  #   @hisseki = Hisseki.new
  # end

  # def create_hisseki
  #   @hisseki = Hisseki.new(hisseki_params)
  #
  #   respond_to do |format|
  #     if @hisseki.save
  #       format.html { redirect_to @hisseki, notice: "Hisseki was successfully created." }
  #       format.json { render :show, status: :created, location: @hisseki }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @hisseki.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_hisseki
    @hisseki = Hisseki.find(params[:id])
  end

  def hisseki_params
    all_params =
    begin
      params.require(:hisseki).permit(:image)
    rescue
      params.permit(:image_data_uri)
    end
    all_params[:user_id] = session[:user_id]
    all_params
  end
end
