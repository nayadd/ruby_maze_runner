require 'gosu'
require 'rmagick'

require_relative 'resources/distance_grid'
require_relative 'resources/wilsons'
require_relative 'resources/player'

WIDTH, HEIGHT = 200, 200


class GameWindow < Gosu::Window
  def initialize
    super WIDTH, HEIGHT
    self.caption = "Grid Creation Test"


    @grid = Grid.new(HEIGHT/10, WIDTH/10)
    Wilsons.on(@grid)


    puts "Setting start cell on Grid"
    start = @grid[0,0]

    puts "Calculating distances from Start cell"
    distances = start.distances

    puts "Defining the most distant point as new starting cell"
    new_start, distance = distances.max

    puts "Calculating distances from New Starting cell"
    new_distances = new_start.distances
    puts "Defining the most distant point as goal cell"
    @goal_cell, distance = new_distances.max


    canvas = @grid.to_rmagick
    @background_image = Gosu::Image.new(canvas, :tileable => true)
    @player = Player.new
    @player.warp(new_start.column*10, new_start.row*10)
    @goal = Gosu::Font.new(10)
  end

  def update
    row = @player.location[0]/10
    column = @player.location[1]/10
    cell = @grid[row,column]
    delay_time = 0.1

    if @player.grid_location == @goal_cell.location
      puts "Goal Reached!"
    end

    if Gosu::button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft then
      @player.walk(:left) if cell.has_west_neighbor?
      sleep delay_time
    end
    if Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight then
      @player.walk(:right) if cell.has_east_neighbor?
      sleep delay_time
    end
    if Gosu::button_down? Gosu::KbUp or Gosu::button_down? Gosu::GpButton0 then
      @player.walk(:forward) if cell.has_north_neighbor?
      sleep delay_time
    end
    if Gosu::button_down? Gosu::KbDown or Gosu::button_down? Gosu::GpButton1 then
      @player.walk(:back) if cell.has_south_neighbor?
      sleep delay_time
    end
  end

  def draw
    @player.draw
    @background_image.draw(0, 0, 0)
    @goal.draw("G",@goal_cell.column*10,@goal_cell.row*10, 1, 1.0, 1.0, 0xff_ff0000)
  end

end

window = GameWindow.new
window.show
