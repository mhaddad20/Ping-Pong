require 'ruby2d'


set background: 'random' # random background color
set height: 420
set width: 440
set fps_cap: 60 # speed of the game

NUM_LINES=10 # display number of lines on the screen
HEIGHT = 150 # height of each paddle
OPPONENT_DELAY = 20
BALL_VELOCITY=6 # speed of the ball

class DivideLine # divide each line in the middle of the screen, creating gaps
  def draw
    NUM_LINES.times do |x|
      Rectangle.new(x:(Window.width/2),y:(x*(Window.height/10)),width:Window.width/20,height:Window.height/20,color:'white')
    end
  end
end

class Paddle
  attr_writer :direction # allows to edit the direction inside this class
  attr_reader :side # allows to edit the side inside this class


  def initialize(side,speed)
    @speed=speed # set speed of the paddle
    @side=side # set which side of the paddle this is for
    @y=120 #starting height of the paddle
    @direction=nil
    if(side=='left')
      @x=20 # set the location of the paddle away from the left by some distance
    else
      @x=Window.width-40 # set the location of the paddle away from the left by some distance
    end
  end
  def move
    if @direction=='down' # move the paddle down
      @y =[@y+@speed,Window.height-HEIGHT].min # move the paddle so that it does not go out of bounds
    elsif @direction=='up'
      @y =[@y-@speed,0].max # move the paddle so that it does not go out of bounds
    end

  end

  def draw
    @shape = Rectangle.new(x:@x,y:@y,width:20,height:HEIGHT,color: 'white') #set color of paddle
  end

  def hit_ball?(ball)# check if the top-right or top-left of the ball has hit the paddle
    ball.shape &&[[ball.shape.x1, ball.shape.y1],[ball.shape.x2, ball.shape.y2],
                  [ball.shape.x3,ball.shape.y3],[ball.shape.x4,ball.shape.y4]].any? do |coordinates|
      @shape.contains?(coordinates[0],coordinates[1])
    end
  end

  def ball_height_player
    @y +(HEIGHT/2) # middle height of the ball
  end
  def ball_height_opponent
    @y +(HEIGHT/2) # middle height of the ball
  end
  def y1
    @shape.y1 # coordinates of the height of the ball
  end
end


class Ball
  HEIGHT_BALL=20 # size of the ball
  attr_reader :shape

  def initialize(speed)
    @x=320 #position of the ball
    @y=240 #position of the ball
    @x_speed =-speed # move the ball through the opposite x-axis
    @y_speed =speed # move the ball through the y-axis
    @speed=speed
  end
  def move
    if hit_bottom? || hit_top?
      @y_speed=-@y_speed # opposite the y-axis after it hits the top or bottom of the screen
    end
    @x+=@x_speed # add more speed to the ball
    @y+=@y_speed
  end
  def draw
    @shape =Square.new(x:@x,y: @y,size: HEIGHT_BALL,color:'white') # color,size of the ball
  end
  def hit_bottom?
    @y+HEIGHT_BALL>=Window.height
  end
  def hit_top?
    @y<=0
  end
  def bounce(paddle)
    if @last_side!=paddle.side # bounce the ball according to which side of the paddle it bounced off
      center_range = HEIGHT/100*5
      position = ((@shape.y1 - paddle.y1) / HEIGHT.to_f)
      angle = position.clamp(0.2, 0.8) * Math::PI # calculate the angle when deciding to bounce the all the other way
      if paddle.side == 'left'
        @x_speed = Math.sin(angle) * @speed
        @y_speed = -Math.cos(angle) * @speed
      else
        @x_speed = -Math.sin(angle) * @speed
        @y_speed = -Math.cos(angle) * @speed
      end
      if ball_height<paddle.ball_height_player-center_range ||ball_height>paddle.ball_height_player+center_range
        @speed+=1 # increasing the speed of the ball which each hit of the paddle
        puts @speed
      else
        @speed=BALL_VELOCITY # neutralizing the ball speed after it hits the middle of the paddle
        puts ball_height," ",paddle.ball_height_player
        puts @speed

      end


    @last_side=paddle.side
    end
  end
  def ball_height
    @y
  end
  def bounds?
    @x<=0 || @x>=Window.width # check if ball is out of bounds
  end
end




player1 = Paddle.new('left',10) # player is left paddle, speed of the paddle is 10
opponent = Paddle.new('right',10) # opponent is right paddle, speed of the paddle is 10
ball=Ball.new(BALL_VELOCITY)
boom = Music.new('CLOUD UPDJ KIMERA.mp3') # add music to the background
loop =true # loop music track
boom.play # play music
divide = DivideLine.new

last_hit_frame=0 # to record which frame the ball was hit
update do
  clear
  if player1.hit_ball?(ball)
    ball.bounce(player1)
    last_hit_frame=Window.frames
  end
  if opponent.hit_ball?(ball)
    ball.bounce(opponent)
    last_hit_frame=Window.frames
  end


  player1.move

  player1.draw
  divide.draw

  if ball.bounds?
    ball = Ball.new(BALL_VELOCITY)
  end
  ball.move

  ball.draw
  opponent.move
  opponent.draw

end

on :key_down do |event| # detect key from user
  case event.key
  when 'down'
    opponent.direction='down'
  when 'up'
    opponent.direction='up'
  when 'w'
    player1.direction='up'
  when 's'
    player1.direction='down'
  end
end

on :key_up do |event| # stop moving the paddle when no key is pressed
  player1.direction=nil
  opponent.direction =nil
end

show
