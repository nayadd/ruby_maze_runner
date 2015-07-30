require 'gosu'
require 'rmagick'

require_relative 'distance_grid'
require_relative 'wilsons'

WIDTH, HEIGHT = 200, 200


class Grid

  def to_rmagick(cell_size: 10)
    img_width = cell_size * columns
    img_height = cell_size * rows

    canvas = Magick::ImageList.new
    canvas.new_image(WIDTH, HEIGHT)

    background = ChunkyPNG::Color::WHITE
    wall = ChunkyPNG::Color::BLACK

    img = Magick::ImageList.new
    img.new_image(img_width , img_height )


    [:backgrounds, :walls].each do |mode|
      each_cell do |cell|
        gc = Magick::Draw.new
        gc.stroke('black')
        x1 = cell.column * cell_size
        y1 = cell.row * cell_size
        x2 = (cell.column + 1) * cell_size
        y2 = (cell.row + 1) * cell_size

        if mode == :backgrounds
          color = background_color_for(cell)
          gc.rectangle(x1, y1, x2, y2, color, color) if color
        else
          gc.line(x1, y1, x2, y1) unless cell.north
          gc.line(x1, y1, x1, y2) unless cell.west
          gc.line(x2, y1, x2, y2) unless cell.linked?(cell.east)
          gc.line(x1, y2, x2, y2) unless cell.linked?(cell.south)
        end
        gc.draw(img)
      end
    end
    img
  end
end

class Player
  def initialize
    #@image = Gosu::Image.new("media/Starfighter.bmp")
    @x = @y  = 0.0
    @score = 0
    @font = Gosu::Font.new(25)
  end

  def location
    [@x, @y]
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def move
    @x %= WIDTH
    @y %= HEIGHT
  end

  def left
    @x -= 10
  end

  def right
    @x += 10
  end

  def forward
    @y -= 10
  end

  def back
    @y += 10
  end

  def walk(direction)
    case direction
    when :left then left
    when :right then right
    when :forward then  forward
    when :back then  back
    end
  end

  def draw
    #@image.draw_rot(@x, @y, 1, @angle)
    @font.draw("*",@x, @y, 1, 1.0, 1.0, 0xff_ff0000)
  end
end


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
    row = @player.location[1]/10
    column = @player.location[0]/10
    cell = @grid[row,column]
    delay_time = 0.1

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
