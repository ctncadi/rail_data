class Admin::OneRakeLoadsController < ApplicationController
  layout "admin/application"

  def index
    @one_rake_loads = RakeLoad.where(rakeform_otherform: "R")
  end
  

  def show
    
  end

  def new
    data = params[:data].to_date if params[:data].present?
    data = Date.today if data.blank?
    # data = data.strftime("%Y-%m-%d")
    @one_rake_loads = RakeLoad.where(release_date: data,rakeform_otherform: "R")

    current_user_one_rake_load = []
      @one_rake_loads.each do |one_rake_load|
        rake_area =  one_rake_load.load_unload.station.area.area_code rescue nil
        current_user_area = current_user.area rescue nil
        
        if rake_area == current_user_area
          # load_unit = load_unit+one_rake_load.loaded_unit
          current_user_one_rake_load << one_rake_load
        end
      end
    @one_rake_loads = current_user_one_rake_load
    
     @total_rake_loads = (RakeLoad.where(release_date: data,rakeform_otherform: "R"))
      load_unit = 0
      @total_rake_loads.each do |total_rake_load|
        rake_area =  total_rake_load.load_unload.station.area.area_code rescue nil
        current_user_area = current_user.area rescue nil
        
        if rake_area == current_user_area
          load_unit = load_unit+total_rake_load.loaded_unit
        end
      end
    @total_rake_loads = load_unit
    
    @total_other_loads = (RakeLoad.where(release_date: data,rakeform_otherform: "O"))
      load_unit = 0
      @total_other_loads.each do |total_other_load|
        rake_area =  total_other_load.load_unload.station.area.area_code rescue nil
        current_user_area = current_user.area rescue nil
        
        if rake_area == current_user_area
          load_unit = load_unit+total_other_load.loaded_unit
        end
      end
    @total_other_loads = load_unit

    get_data_for_form
  end


  def get_data_for_form
    # @from_stations = []
    # LoadUnload.all.each do |load|
    #   station = Station.find(load.station_id) rescue nil
    #   @from_stations << [station.code, station.id] if station.present?
    # end  
    # @to_stations = Station.all.map{|station| [station.code,station.id]}
    @major_commodity = MajorCommodity.all.map{|major|[major.major_commodity,major.id]}
    @wagon_type = WagonType.all.map{|wagon| [wagon.stock_type_code,wagon.id]}
    @rake_commodity = {}
    MajorCommodity.all.each do |major|
    rake_commodity_array = major.rake_commodities.map{|rake_commodity| ["#{rake_commodity.rake_commodity_code}-#{rake_commodity.rake_commodity_name}",rake_commodity.id]}
      @rake_commodity[major.id] = {data: rake_commodity_array.sort}
    end
    
  end  

  def create
   if params[:is_rake_commodity].present? and params[:is_rake_commodity] == "true"
     CreateRakeLoadsRakeCommodity.create_rake_loads_rake_commodity(params)
   else
     RakeLoad.create_or_update_one_rake_load(params)
     data = params["date"].to_date if params["date"].present?
     data = Date.today if data.blank?
     # data = data.strftime("%Y-%m-%d")
     @one_rake_loads = RakeLoad.where(release_date: data,rakeform_otherform: "R")
     @total_rake_loads = (RakeLoad.where(release_date: data,rakeform_otherform: "R").pluck(:loaded_unit)).sum
     @total_other_loads = (RakeLoad.where(release_date: data,rakeform_otherform: "O").pluck(:loaded_unit)).sum
     get_data_for_form
   end
 end

  # def load_commodity_breakup
  #   rake_load_id = params[:rake_load_id]
  #   @load_commodity_breakup_values =  CreateRakeLoadsRakeCommodity.where(rake_load_id: rake_load_id)
    
  #     respond_to do |format|
  #       format.js
  #     end
    
  # end
  def load_commodity_breakup
    @rake_load_id = params[:rake_load_id]
    @rake_load = RakeLoad.find(@rake_load_id)
    @major_commodity_id = @rake_load.major_commodity_id
    @load_commodity_breakup_values =  CreateRakeLoadsRakeCommodity.where(rake_load_id: @rake_load_id)
    @rake_loads_rake_commodity_ids  = @load_commodity_breakup_values.pluck(:rake_commodity_id)
    get_data_for_form
    respond_to do |format|
      format.js
    end
  end

  def edit
    get_data_for_form
  end

  def update
    
  end

  def destroy
    
  end


end
