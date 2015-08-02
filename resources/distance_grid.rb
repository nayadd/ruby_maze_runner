require_relative 'grid'

class DistanceGrid < Grid
  attr_accessor :distances
  attr_accessor :max_distance

  def distances=(distances)
    @distances = distances
    farthest, @maximum = distances.max
  end

  def background_color_for(cell)
    if distances && distances[cell]
      'yellow'
    else
      'white'
    end
  end

  def max_distance
    @max_distance.to_i
  end

  def contents_of(cell)
    if distances && distances[cell]
      num = distances[cell].to_s(36)
      pad = max_chars - num.length
      ' '*pad + num
    else
      super
    end
  end
end
