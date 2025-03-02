class CheckInsController < ApplicationController
  before_action :set_check_in, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  # GET /check_ins or /check_ins.json
  def index
    @check_ins = CheckIn.all
  end

  # GET /check_ins/1 or /check_ins/1.json
  def show
  end

  # GET /check_ins/new
  def new
    @check_in = CheckIn.new
  end

  # GET /check_ins/1/edit
  def edit
  end

  # POST /check_ins or /check_ins.json
  def create
    booking = Booking.find_by(id: params[:booking_id], user: current_user)
  
    if booking && booking.confirmation_code == params[:confirmation_code]
      @check_in = CheckIn.new(user: current_user, booking: booking, check_in: Time.now)
  
      if @check_in.save
        render json: { message: "Check-in สำเร็จ!" }, status: :ok
      else
        render json: { errors: @check_in.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: "รหัสยืนยันไม่ถูกต้อง หรือไม่มีข้อมูลการจอง" }, status: :unprocessable_entity
    end
  end
  

  # PATCH/PUT /check_ins/1 or /check_ins/1.json
  def update
    respond_to do |format|
      if @check_in.update(check_in_params)
        format.html { redirect_to @check_in, notice: "Check in was successfully updated." }
        format.json { render :show, status: :ok, location: @check_in }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @check_in.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /check_ins/1 or /check_ins/1.json
  def destroy
    @check_in.destroy!

    respond_to do |format|
      format.html { redirect_to check_ins_path, status: :see_other, notice: "Check in was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_check_in
      @check_in = CheckIn.find(params[:id])
    end    

    # Only allow a list of trusted parameters through.
    def check_in_params
      params.require(:check_in).permit(:booking_id, :confirmation_code)
    end
end
