class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    
    @all_ratings = Movie.all_ratings
    
    if params[:ratings].nil? and params[:commit] 
      session.delete(:ratings) 
      session.delete(:sort) 
    end
    
    @all_ratings = Movie.all_ratings
    @checked = params[:ratings] || session[:ratings] || Hash[@all_ratings.map {|rating| [rating, 1]}]
    
    sort = params[:sort] || session[:sort]
    
    if sort == "title"
      @title_header = 'bg-warning'
      @release_date_header = ''
    end
    
    if sort == "release_date"
      @release_date_header = 'bg-warning'
      @title_header = ''
    end
    

    if params[:sort] != session[:sort] || params[:ratings] != session[:ratings]
      session[:sort] = sort
      session[:ratings] = @checked
      
      if !params[:ratings] && !params[:sort] && params[:home]
        session[:ratings] = Hash[@all_ratings.map {|rating| [rating, 1]}]
      end
      redirect_to sort: session[:sort], ratings: session[:ratings] and return
    end
    
       @movies = Movie.where(rating: @checked.keys).order(sort) 
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
