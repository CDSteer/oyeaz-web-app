class LocationsController < ApplicationController
	# localhost:3000/users/1/locations/new?latitude=1&longitude=1
	def index
	end

	def show
		if current_user
			@user = User.find(params[:user_id])
		else
			@user = User.find(params[:user_id])
			@js_response = ActiveSupport::JSON.encode(@user.location)
			respond_to do |format|
				format.json { render :json => @js_response}
				format.html
			end
			# redirect_to root_path
		end
	end

	def new
		if current_user
			getLocation
			@user = User.find(params[:user_id])
			if @user.location
				@location = @user.location.update(:latitude => @latitude, :longitude => @longitude, :user_id => @user.id)
			else
				@location = Location.create(:latitude => @latitude, :longitude => @longitude, :user_id => @user.id)
				@location.save
			end
			redirect_to user_location_path(current_user.id, current_user.location.id)
		else
			@user = User.find(params[:user_id])
			if @user.location
				@location = @user.location.update(:latitude => params[:latitude], :longitude => params[:longitude], :user_id => @user.id)
				@user2 = User.find(compareLocation)
				@js_response = ActiveSupport::JSON.encode(@user2.contents.all)
				respond_to do |format|
					format.json { render :json => @js_response}
					format.html
				end
			else
				@location = Location.create(:latitude => params[:latitude], :longitude => params[:longitude], :user_id => @user.id)
			end
		end
	end

 	def destroy
 		if current_user
			@user = User.find(params[:user_id])
			@user.location.destroy
			redirect_to user_path(current_user)
		else
			redirect_to root_path
		end
	end

  private
	  def getLocation
	    @lat_lng = "0|0"
			@lat_lng = cookies[:lat_lng].split("|")
			@latitude = @lat_lng.at(0)
			@longitude = @lat_lng.at(1)
		end

		def compareLocation
			tree = treeLocations
			results = tree.nearest_geo_range([@user.location.latitude, @user.location.longitude], 0.1)
			puts(results.size)
			return results[0].data.inspect
		end

		def treeLocations
			tree = Geokdtree::Tree.new(2)
			x = User.count
			puts x
			for i in 1..3
				user = User.find_by_id(i)
				tree.insert([user.location.latitude, user.location.longitude], i)
			end
			return tree
		end
end
