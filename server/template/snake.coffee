# Game logic

# Tile state enum
tilestates =
  NONE: 0
  HEAD: 1
  TAIL: 2
  FOOD: 3

# Direction enum
directions =
  UP: 0
  DOWN: 1
  LEFT: 2
  RIGHT: 3

# Container class for tiles and their states
class Tile
  constructor: ->
    @state = tilestates.NONE

# Board class
class Board
  constructor: ->
    # Fill board
    @tiles = for x in [0...4]
      for y in [0...4]
        new Tile

    # Decide starting place
    rand = Math.floor (Math.random * 100)
    x = (rand / 10) / 2
    y = (rand % 10) / 2
    @snake = []
    @snake.push [x, y]
    @tiles[x][y].state = tilestates.HEAD

    # Determine ideal starting direction (left or right, default left)
    if x < 3
      @direction = directions.RIGHT
    else
      @direction = directions.LEFT

    populatefood

  # Move head of snake. If grow is false, the very end is removed.
  move: =>
    if @direction in directions and @dead is false
      newhead = []

      # Get hypothetical new head coords
      if @direction is directions.UP
        newhead = [@snake[0][0], @snake[0][1] - 1]
      else if @direction is directions.DOWN
        newhead = [@snake[0][0], @snake[0][1] + 1]
      else if @direction is directions.LEFT
        newhead = [@snake[0][0] - 1, @snake[0][1]]
      else if @direction is directions.RIGHT
        newhead = [@snake[0][0] + 1, @snake[0][1]]

      # Ensure next tile is within bounds
      if newhead[0] < 0 or newhead[0] > 4 or newhead[1] < 0 or newhead[1] > 4
        @dead = true
      else if @tiles[newhead[0]][newhead[1]].state is tilestates.TAIL
        @dead = true
      else if @tiles[newhead[0]][newhead[1]].state is tilestates.HEAD
        @dead = true
      else

        # Pop end of snake if grow is false, and
        # make sure it knows whether to do this on the next move.
        if @grow is false
          endx = @snake[@snake.length - 1][0]
          endy = @snake[@snake.length - 1][1]
          @tiles[endx][endy].state = tilestates.NONE
          @snake.pop

        newfood = false

        if @tiles[newhead[0]][newhead[1]].state is tilestates.FOOD
          @grow = true
          newfood = true
        else
          @grow = false

        @tiles[newhead[0]][newhead[1]].state = tilestates.HEAD
        @tiles[snake[0][0]][snake[0][1]].state = tilestates.TAIL

        snake.unshift [newhead[0], newhead[1]]

        if newfood
          populatefood

  # Called when the food on the board has been
  # eaten and needs to be repopulated.
  populatefood: =>
    while true
      rand = Math.floor (Math.random * 100)
      x = (rand / 10) / 2
      y = (rand % 10) / 2
      if @tiles[x][y].state is tilestates.NONE
        @tiles[x][y].state = tilestates.FOOD
        break

SnakeViewModel =
  start: =>
    if @board is undefined or @board == null or @board.dead
      @board = new Board

  stateImage: ko.computed (x, y) ->
    if @board.tiles[x][y] is tilestates.NONE
      'url("img/none.png")'
    else if @board.tiles[x][y] is tilestates.TAIL
      'url("img/tail.png")'
    else if @board.tiles[x][y] is tilestates.FOOD
      'url("img/food.png")'
    else if @board.tiles[x][y] is tilestates.HEAD
      if @board.direction is directions.UP
        'url("img/headup.png")'
      else if @board.direction[x][y] is directions.DOWN
        'url("img/headdown.png")'
      else if @board.direction[x][y] is directions.LEFT
        'url("img/headleft.png")'
      else if @board.direction[x][y] is directions.RIGHT
        'url("img/headright.png")'

  deadOpacity: ko.computed ->
    if @board.dead
      '0.8'
    else
      '0.0'

$(document).keydown (event) ->
  if event.which is 32
    # Space bar starts the game.
    SnakeViewModel.start
  else if event.which is 38
    # Up movement
    SnakeViewModel.board.direction = directions.UP
  else if event.which is 40
    # Down movement
    SnakeViewModel.board.direction = directions.DOWN
  else if event.which is 37
    # Left movement
    SnakeViewModel.board.direction = directions.LEFT
  else if event.which is 39
    # Right movement
    SnakeViewModel.board.direction = directions.RIGHT
