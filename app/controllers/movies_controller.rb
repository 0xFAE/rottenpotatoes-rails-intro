class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    
    @all_ratings = Movie.all_ratings
    
    if !params[:sort].nil?
       sort = params[:sort]
      session[:sort] = sort
    else
      sort = session[:sort]
    end
    
    if !params[:ratings].nil?
      @checked = params[:ratings]
      session[:ratings] = @checked
    else
      @checked = session[:ratings] || Hash[@all_ratings.map {|rating| [rating, 1]}]
    end
    
    if !params[:sort] && !params[:ratings]
      flash.keep
      redirect_to movies_path(:ratings => @checked, :sort => sort) and return
    end
    
    if sort == 'title'
      @title_header = 'bg-warning'
      @release_date_header = ''
    elsif sort == 'release_date'
      @release_date_header = 'bg-warning'
      @title_header = ''
    end
    
       @movies = Movie.order(sort).where(rating: @checked)
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
