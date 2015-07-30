require 'gosu'
require 'chunky_png'
class Distances
  def initialize(root)
    @root =  root
    @cells = {}
    @cells[@root] = 0
  end

  def [](cell)
    @cells[cell]
  end

  def []=(cell, distance)
    @cells[cell] = distance
  end

  def cells
    @cells.keys
  end

  def path_to(goal)
    current = goal

    breadcrumbs = Distances.new(@root)
    breadcrumbs[current] = @cells[current]

    until current == @root
      current.links.each do |neighbor|
        if @cells[neighbor] < @cells[current]
          breadcrumbs[neighbor] = @cells[neighbor]
          current = neighbor
          break
        end
      end
    end
    breadcrumbs
  end

  def max
    max_distance = 0
    max_cell = @root
    @cells.each do |cell, distance|
      if distance > max_distance
        max_cell = cell
        max_distance = distance
      end
    end
    [max_cell, max_distance]
  end
end

class Cell
  attr_reader :row, :column
  attr_accessor :north, :south, :east, :west

  def initialize(row, column)
    @row, @column = row,  column
    @links = {}
  end

  def link(cell, bidi=true)
    @links[cell] = true
    cell.link(self, false) if bidi
    self
  end

  def unlink(cell, bidi=true)
    @links.delete(cell)
    cell.unlink(self, false) if bidi
    self
  end

  def links
    @links.keys
  end

  def linked?(cell)
    @links.key?(cell)
  end

  def neighbors
    list = []
    list << north if north
    list << south if south
    list << east if east
    list << west if west
    list
  end

  def distances
    distances = Distances.new(self)
    frontier =  [ self ]

    while frontier.any?
      new_frontier = []

      frontier.each do |cell|
        cell.links.each do |linked|
          next if distances[linked]
          distances[linked] = distances[cell] + 1
          new_frontier << linked
        end
      end

      frontier = new_frontier
    end
    distances
  end

end

class Grid
  attr_reader :rows, :columns

  def initialize(rows, columns)
    @rows = rows
    @columns = columns
    @grid = prepare_grid
    configure_cells
  end

  def prepare_grid
    Array.new(rows) do |row|
      Array.new(columns) do |column|
        Cell.new(row, column)
      end
    end
  end

  def configure_cells
    each_cell do |cell|
      row = cell.row
      col = cell.column
      cell.north = self[row - 1, col]
      cell.south = self[row + 1, col]
      cell.west = self[row, col - 1]
      cell.east = self[row, col + 1]
    end
  end

  def [](row, column)
    return nil unless row.between?(0, @rows - 1)
    return nil unless column.between?(0, @grid[row].count - 1)
    @grid[row][column]
  end

  def random_cell
    row = rand(@rows)
    column = rand(@grid[row].count)
    self[row, column]
  end

  def size
    @rows * @columns
  end

  def each_row
    @grid.each do |row|
      yield row
    end
  end

  def each_cell
    each_row do |row|
      row.each do |cell|
        yield cell if cell
      end
    end
  end

  def contents_of(_cell)
    ' ' * max_chars
  end

  def background_color_for(_cell)
    nil
  end

  def max_distance
    0
  end

  def max_chars
    max_distance / 36 + 1
  end

  def to_s(step:false)
    output = '+' + "-#{'-' * max_chars}-+" * columns + "\n"
    i = 1
    each_row do |row|
      top = '|'
      bottom = '+'

      row.each do |cell|
        cell = Cell.new(-1, -1) unless cell

        body = " #{contents_of(cell)} "

        east_boundary = (cell.linked?(cell.east) ? ' ' : '|')
        top << body << east_boundary

        south_boundary = (cell.linked?(cell.south) ? " #{' ' * max_chars} " : "-#{'-' * max_chars}-")
        corner = '+'
        bottom << south_boundary << corner
      end

      output << top << "\n"
      output << bottom << "\n"
      if step
        puts "Row #{i} of #{rows}:"
        puts output
        puts "\n"
        i += 1
      end
    end
    puts 'Final Result:' if step
    output
  end

  def to_png(cell_size: 10)
    img_width = cell_size * columns
    img_height = cell_size * rows

    background = ChunkyPNG::Color::WHITE
    wall = ChunkyPNG::Color::BLACK

    img = ChunkyPNG::Image.new(img_width + 1, img_height + 1, background)

    [:backgrounds, :walls].each do |mode|
      each_cell do |cell|
        x1 = cell.column * cell_size
        y1 = cell.row * cell_size
        x2 = (cell.column + 1) * cell_size
        y2 = (cell.row + 1) * cell_size

        if mode == :backgrounds
          color = background_color_for(cell)
          img.rect(x1, y1, x2, y2, color, color) if color
        else
          img.line(x1, y1, x2, y1, wall) unless cell.north
          img.line(x1, y1, x1, y2, wall) unless cell.west
          img.line(x2, y1, x2, y2, wall) unless cell.linked?(cell.east)
          img.line(x1, y2, x2, y2, wall) unless cell.linked?(cell.south)
        end
      end
    end

    img
  end
end

class ColoredGrid < Grid
  def distances=(distances)
    @distances = distances
    farthest, @maximum = distances.max
  end

  def background_color_for(cell)
    distance = @distances[cell] or return nil
    intensity = (@maximum - distance).to_f / @maximum
    dark = (255 * intensity).round
    bright = 128 + (127 * intensity).round
    ChunkyPNG::Color.rgb(dark, bright, dark)
  end
end
class Wilsons

  def self.on(grid)
    unvisited = []
    grid.each_cell { |cell| unvisited << cell }

    first = unvisited.sample
    unvisited.delete(first)

    while unvisited.any?
      cell = unvisited.sample
      path = [cell]

      while unvisited.include?(cell)
        cell = cell.neighbors.sample
        position = path.index(cell)
        if position
          path = path[0..position]
        else
          path << cell
        end
      end

      0.upto(path.length-2) do |index|
        path[index].link(path[index + 1])
        unvisited.delete(path[index])
      end
    end

    grid
  end

end

class GameWindow < Gosu::Window
  def initialize
    super 640, 480
    self.caption = "Gosu Test"
    @font = Gosu::Font.new(20)

    grid = Grid.new(20, 20)
    Wilsons.on(grid)
    filename = "background#{Time.now}.png"
    grid.to_png.save(filename)
    @background = @background_image = Gosu::Image.new(filename, :tileable => true)
  end

  def update
  end

  def draw
    @font.draw("Score: 100", 10, 10, 0, 1.0, 1.0, 0xff_ffff00)
    @background_image.draw(0, 0, 0)
  end

end

window = GameWindow.new
window.show
