class Player
  def initialize
    @x = @y  = 0.0
    @score = 0
    @font = Gosu::Font.new(25)
  end

  def grid_location
    [@y/10, @x/10]
  end

  def location
    [@y, @x]
  end

  def warp(x, y)
    @x, @y = x, y
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
