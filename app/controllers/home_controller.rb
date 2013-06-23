class HomeController < ApplicationController
  def index
    if user_signed_in?
      @meters = current_user.meters
      
      @current_values = Hash.new()
      @meters.each do |meter|
        @readings = Reading.all.select { |r| r.meter_id == meter.id }
        unless @readings.empty?
          @readings_day = @readings.group_by { |m| Date.parse(m.created_at.beginning_of_day.to_s) }
          sorted_readings = @readings.sort{|a,b| b.value <=> a.value}
          @current_values[meter] = sorted_readings.first.value + (sorted_readings.first.value - sorted_readings.last.value) / (@readings_day.keys.max - @readings_day.keys.min) * (Date.today - @readings_day.keys.max)
        end
      end
    end
    
  end

end
