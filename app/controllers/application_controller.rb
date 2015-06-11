class ApplicationController < ActionController::Base
	protect_from_forgery
	def new
	end

	def create
		render plain: params[:article].inspect
	end

	private
		def current_user
			@current_user ||= User.find(session[:user_id]) if session[:user_id]
		end
	helper_method :current_user
end