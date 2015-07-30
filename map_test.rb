require 'gosu'
require 'rmagick'

require_relative 'resources/distance_grid'
require_relative 'resources/wilsons'
require_relative 'resources/player'

WIDTH, HEIGHT = 200, 200


class GameWindow < Gosu::Window
  def initialize
    super WIDTH, HEIGHT
    self.caption = "Ruby Maze Runner"


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
    @goal = Gosu::Image.new("goal2.png")
    @victory = Gosu::Image.new("winner.png")
    @victory_sound = Gosu::Sample.new("win.mp3")

  end

  def update
  end

  def draw
    @player.draw
    @background_image.draw(0, 0, 0)
    @goal.draw(@goal_cell.column*10,@goal_cell.row*10,1)

    if @player.grid_location == @goal_cell.location
      vheight=(HEIGHT-@victory.height)/2
      vwidth =(WIDTH-@victory.width)/2
      @victory.draw(vheight,vwidth,1)
    end

  end

  def button_down(id)
    row = @player.location[0]/10
    column = @player.location[1]/10
    cell = @grid[row,column]

    case id
      when Gosu::KbLeft   then @player.walk(:left) if cell.has_west_neighbor?
      when Gosu::KbRight  then @player.walk(:right) if cell.has_east_neighbor?
      when Gosu::KbUp     then @player.walk(:forward) if cell.has_north_neighbor?
      when Gosu::KbDown   then @player.walk(:back) if cell.has_south_neighbor?
      when Gosu::KbEscape then Gosu::Window.close
    end

    if @player.grid_location == @goal_cell.location
      @victory_sound.play
    end
  end

end

window = GameWindow.new
window.show
