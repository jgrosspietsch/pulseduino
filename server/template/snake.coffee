# Tile state enum

tilesstyles =
  NONE: 'url("img/none.png")'
  HEADUP: 'url("img/headup.png")'
  HEADDOWN: 'url("img/headdown.png")'
  HEADLEFT: 'url("img/headleft.png")'
  HEADRIGHT: 'url("img/headright.png")'
  TAIL: 'url("img/tail.png")'
  FOOD: 'url("img/food.png")'

# Directions enum

directions =
  UP: 0
  DOWN: 1
  LEFT: 2
  RIGHT: 3

snake = angular.module 'pulseduino', []

snake.controller 'SnakeController',['$scope', ($scope) ->
  $scope.tiles = []
  for i in [0..24]
    $scope.tiles[i] = tilesstyles.NONE

  $scope.dead = true
  $scope.overlayopacity = ->
    if $scope.dead is true
      '0.8'
    else
      '0.0'
  $scope.snake = []
  $scope.direction = directions.LEFT
  $scope.socket = null

  $scope.getTile = (n) ->
    return $scope.tiles[n]

  $scope.initBoard = ->
    if $scope.dead is true
      for i in [0..24]
        $scope.tiles[i] = tilesstyles.NONE

      $scope.snake = []

      n = Math.floor (Math.random() * 25)
      x = n % 5

      $scope.snake.push n

      if x < 3
        $scope.direction = directions.RIGHT
        $scope.tiles[n] = tilesstyles.HEADRIGHT
      else
        $scope.direction = directions.LEFT
        $scope.tiles[n] = tilesstyles.HEADLEFT

      $scope.populateFood()
      $scope.dead = false
      return

  $scope.populateFood = ->
    while true
      n = Math.floor (Math.random() * 25)
      if $scope.tiles[n] is tilesstyles.NONE
        $scope.tiles[n] = tilesstyles.FOOD
        return

  $scope.move = ->
    if $scope.dead is false
      currentn = $scope.snake[0]
      currentx = currentn % 5
      currenty = Math.floor(currentn / 5)

      if $scope.direction is directions.UP and currenty < 1
        $scope.dead = true
      else if $scope.direction is directions.DOWN and currenty > 3
        $scope.dead = true
      else if $scope.direction is directions.LEFT and currentx < 1
        $scope.dead = true
      else if $scope.direction is directions.RIGHT and currentx > 3
        $scope.dead = true
      else
        # Head appears to be able to stay within bounds
        newx = currentx
        newy = currenty

        if $scope.direction is directions.UP
          newy--
        else if $scope.direction is directions.DOWN
          newy++
        else if $scope.direction is directions.LEFT
          newx--
        else if $scope.direction is directions.RIGHT
          newx++

        newn = newx + (newy * 5)

        if $scope.tiles[newn] is tilesstyles.TAIL
          $scope.dead = true
        else
          grow = false
          if $scope.tiles[newn] is tilesstyles.FOOD
            grow = true
          $scope.snake.unshift newn
          $scope.tiles[$scope.snake[1]] = tilesstyles.TAIL

          # Set head tile
          if $scope.direction is directions.UP
            $scope.tiles[newn] = tilesstyles.HEADUP
          else if $scope.direction is directions.DOWN
            $scope.tiles[newn] = tilesstyles.HEADDOWN
          else if $scope.direction is directions.LEFT
            $scope.tiles[newn] = tilesstyles.HEADLEFT
          else if $scope.direction is directions.RIGHT
            $scope.tiles[newn] = tilesstyles.HEADRIGHT

          if grow is false
            $scope.tiles[$scope.snake.pop()] = tilesstyles.NONE
          else
            $scope.populateFood()
    return

  $scope.onKeydown = ($event) ->
    kc = $event.keyCode
    if kc is 32 and $scope.dead is true
      # Space bar to start game
      # (Only allow this input if game is dead.)
      $scope.initBoard()
    else if $scope.dead is false
      # Only allow direction input if the game is not dead
      if kc is 38
        # Up arrow
        $scope.direction = directions.UP
        $scope.tiles[$scope.snake[0]] = tilesstyles.HEADUP
      else if kc is 40
        # Down arrow
        $scope.direction = directions.DOWN
        $scope.tiles[$scope.snake[0]] = tilesstyles.HEADDOWN
      else if kc is 37
        # Left arrow
        $scope.direction = directions.LEFT
        $scope.tiles[$scope.snake[0]] = tilesstyles.HEADLEFT
      else if kc is 39
        # Right arrow
        $scope.direction = directions.RIGHT
        $scope.tiles[$scope.snake[0]] = tilesstyles.HEADRIGHT
    return

  $scope.connectSocket = ->
    $scope.socket = io.connect location.origin
    $scope.socket.on 'beat', (data) ->
      console.log('beat received')
      if $scope.dead is false
        $scope.move()
        $scope.$apply()
      return
    return

  return
]
