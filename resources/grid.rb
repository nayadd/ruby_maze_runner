require_relative 'cell'
require 'chunky_png'
require 'rmagick'

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

  def background_color_for(cell)
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

  def to_rmagick(cell_size: 10, path:false)
    img_width = cell_size * columns
    img_height = cell_size * rows

    canvas = Magick::ImageList.new
    canvas.new_image(WIDTH, HEIGHT)

    img = Magick::ImageList.new
    img.new_image(img_width , img_height )


    [:backgrounds, :walls].each do |mode|
      each_cell do |cell|
        gc = Magick::Draw.new

        x1 = cell.column * cell_size
        y1 = cell.row * cell_size
        x2 = (cell.column + 1) * cell_size
        y2 = (cell.row + 1) * cell_size

        if mode == :backgrounds
          #color ='green'
          color = path ? background_color_for(cell) : 'white'
          gc.stroke_opacity(0.1)
          gc.stroke(color)
          gc.fill_opacity(0.1)
          gc.fill(color)
          gc.rectangle(x1+2, y1+2, x2-2, y2-2) if color
        else
          gc.stroke('black')
          gc.fill('white')
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
