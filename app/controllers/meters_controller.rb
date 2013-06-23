class MetersController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /meters
  # GET /meters.json
  def index
    @meters = current_user.meters

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @meters }
    end
  end

  # GET /meters/1
  # GET /meters/1.json
  def show
    @meter = Meter.find(params[:id])
    @readings = Reading.all.select { |r| r.meter_id == @meter.id }
    
    unless @readings.empty?
      @readings_day = @readings.group_by { |m| Date.parse(m.created_at.beginning_of_day.to_s) }
      @readings_day.each_key do |date|
        if Array(@readings_day[date]).length > 1
          @readings_day[date] = Array(@readings_day[date].to_a.sort{|a,b| b.value <=> a.value}.first)
        end
      end
      
      @dates = (@readings_day.keys.min..Date.today)
      @months = @dates.map {|d| Date.new(d.year, d.month, 1) }.uniq
      
      @readings_month = @readings.group_by { |m| Date.new(m.created_at.beginning_of_month.year, m.created_at.beginning_of_month.month, 1) }
      @consumption_month = Hash.new
      @months.each do |month|
        if Array(@readings_month[month]).length > 1
          sorted_array = Array(@readings_month[month].to_a.sort{|a,b| b.value <=> a.value})
          days = Date.parse(sorted_array.first.created_at.to_s) - Date.parse(sorted_array.last.created_at.to_s)
          consumption = sorted_array.first.value - sorted_array.last.value
          @consumption_month[month] = consumption / days * 30
          @readings_month[month] = sorted_array.first
        else
          puts
          puts month
          puts (Array(@readings_month[month]) + Array(@readings_month[month.prev_month]) + Array(@readings_month[month.next_month]))
          if !Array(@readings_month[month.prev_month]).empty? or !Array(@readings_month[month.next_month]).empty?
            sorted_array = (Array(@readings_month[month]) + Array(@readings_month[month.prev_month]) + Array(@readings_month[month.next_month])).sort{|a,b| b.value <=> a.value}
            days = Date.parse(sorted_array.first.created_at.to_s) - Date.parse(sorted_array.last.created_at.to_s)
            consumption = sorted_array.first.value - sorted_array.last.value
            puts days, consumption, consumption / days * 30
            @consumption_month[month] = consumption / days * 30
          else
            if !Array(@readings_month[month.prev_month(2)]).empty? or !Array(@readings_month[month.next_month(2)]).empty?
              sorted_array = (Array(@readings_month[month]) + Array(@readings_month[month.prev_month(2)]) + Array(@readings_month[month.next_month(2)])).sort{|a,b| b.value <=> a.value}
              days = Date.parse(sorted_array.first.created_at.to_s) - Date.parse(sorted_array.last.created_at.to_s)
              consumption = sorted_array.first.value - sorted_array.last.value
              puts days, consumption, consumption / days * 30
              @consumption_month[month] = consumption / days * 30
            end
          end
        end
      end
      
      sorted_readings = @readings.sort{|a,b| b.value <=> a.value}
      @current_value = sorted_readings.first.value + (sorted_readings.first.value - sorted_readings.last.value) / (@readings_day.keys.max - @readings_day.keys.min) * (Date.today - @readings_day.keys.max)
      @per_month = (sorted_readings.first.value - sorted_readings.last.value) / (@readings_day.keys.max - @readings_day.keys.min) * 30
      @cost_per_month = @meter.basic_rate + @per_month * @meter.price
      
      @per_year = (sorted_readings.first.value - sorted_readings.last.value) / (@readings_day.keys.max - @readings_day.keys.min) * 365
      @cost_per_year = @meter.basic_rate * 12 + @per_year * @meter.price
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @meter }
    end
  end

  # GET /meters/new
  # GET /meters/new.json
  def new
    @meter = Meter.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @meter }
    end
  end

  # GET /meters/1/edit
  def edit
    @meter = Meter.find(params[:id])
  end

  # POST /meters
  # POST /meters.json
  def create
    @meter = Meter.new(params[:meter])

    respond_to do |format|
      if @meter.save
        format.html { redirect_to @meter, notice: 'Meter was successfully created.' }
        format.json { render json: @meter, status: :created, location: @meter }
      else
        format.html { render action: "new" }
        format.json { render json: @meter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /meters/1
  # PUT /meters/1.json
  def update
    @meter = Meter.find(params[:id])

    respond_to do |format|
      if @meter.update_attributes(params[:meter])
        format.html { redirect_to @meter, notice: 'Meter was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @meter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meters/1
  # DELETE /meters/1.json
  def destroy
    @meter = Meter.find(params[:id])
    @meter.destroy

    respond_to do |format|
      format.html { redirect_to meters_url }
      format.json { head :ok }
    end
  end
end
