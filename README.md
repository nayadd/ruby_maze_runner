# ruby_maze_runner
Testing implementation of a game using Gosu Library and Mazes.

Tested on Ruby 2.2.2p95 - Mac Os X Yosemite

Requirements:
+ Ruby 2 (It's a given, but who knows who is reading this...)
+ Gosu (check https://libgosu.org/ , for platform specific instructions, probably will be something like `gem install gosu` )
+ RMagick (`gem install rmagick`)

To run it `ruby map_test.rb`

You will be greeted by this wonderful image:

![game_screenshot](https://raw.githubusercontent.com/nayadd/ruby_maze_runner/master/game_screenshot.png)


Walking the maze is obvious (USE THE KEYBOARD ARROWS!!)
You are represented by the full glory of the red asterisk, your goal is the checkered flag!

Reach it and you'll be greeted with image and sounds (just a fancy way to say a trophy image and a cheering sound)


![victory_screenshot](https://raw.githubusercontent.com/nayadd/ruby_maze_runner/master/victory_screenshot.png)


Needless to say it's a work in progress

TODO:
+ Menu
+ Even Better Graphics
+ Better Victory Message
+ Time / Movements Counter
+ Auto-Solve / Path Coloring
+ Other Maze Generators / Formats
