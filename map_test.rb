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


    @grid = DistanceGrid.new(HEIGHT/10, WIDTH/10)
    Wilsons.on(@grid)

    start = @grid[0,0]
    distances = start.distances
    new_start, distance = distances.max
    new_distances = new_start.distances
    @goal_cell, distance = new_distances.max
    @grid.distances = new_distances.path_to(@goal_cell)

    @path_reveal=false
    draw_maze(path:@path_reveal)
    
    @player = Player.new
    @player.warp(new_start.column*10, new_start.row*10)
    @goal = Gosu::Image.new("goal2.png")
    @victory = Gosu::Image.new("winner.png")
    @victory_sound = Gosu::Sample.new("win.mp3")

  end

  def draw_maze(path:false)
    canvas = @grid.to_rmagick(path:path)
    @background_image = Gosu::Image.new(canvas, :tileable => true)
  end

  def update
    if button_down?(Gosu::KbS)
      @path_reveal ^= true #using XOR to toggle path reveal state
      draw_maze(path:@path_reveal)
    end
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
      when Gosu::KbEscape then self.close
    end

    if @player.grid_location == @goal_cell.location
      @victory_sound.play
    end
  end

end

window = GameWindow.new
window.show
