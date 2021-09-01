require 'ruby2d'


set background: 'random'
set height: 420
set width: 440
set fps_cap: 60

NUM_LINES=10
HEIGHT = 150
OPPONENT_DELAY = 20
PADDLE_WIDTH=20

class DivideLine
  def draw

    NUM_LINES.times do |x|
      Rectangle.new(x:(Window.width/2),y:(x*(Window.height/10)),width:Window.width/20,height:Window.height/20,color:'white')
    end
  end
end

class Coordinates
  def initialize(x,y,x_speed,y_speed)
    @x=x
    @y=y
    @x_speed=x_speed
    @y_speed=y_speed
  end

  def x_length #calculate the distance between the ball and its target
    if @x_speed >0
      (Window.width-PADDLE_WIDTH-@x)/@x_speed
    else
      (@x-PADDLE_WIDTH)/-@x_speed
    end

  end
  def y_length
    if @y_speed >0
      (Window.height-@y)/@y_speed
    else
      @y/-@y_speed
    end

  end
  def x
    @x+(@x_speed * [x_length,y_length].min) # find the minimum distance for the ball to collide with an object/wall
  end
  def y
    @y+(@y_speed * [x_length,y_length].min)
  end

end

class BallTrajectory
  def initialize(ball)
    @ball=ball
    @y

  end
  def draw # calculate the next position the ball will land
    new_coordinates = Coordinates.new(@ball.x_middle,@ball.y_middle,@ball.x_speed,@ball.y_speed)
    Line.new(x1:@ball.x_middle,y1:@ball.y_middle,x2:new_coordinates.x,y2:new_coordinates.y,color: 'black')
    @y=new_coordinates.y
    k=Coordinates.new(new_coordinates.x,new_coordinates.y,@ball.x_speed,@ball.y_speed*-1)
    if new_coordinates.y>=Window.height
      Line.new(x1:new_coordinates.x,y1:new_coordinates.y,x2:k.x,y2:k.y,color: 'black')
      @y=k.y
    elsif new_coordinates.y<=Window.height
      Line.new(x1:new_coordinates.x,y1:new_coordinates.y,x2:k.x,y2:k.y,color: 'black')
      @y=k.y
    end
  end

  def paddle_height
    @y
  end

end

class Paddle
  attr_writer :direction
  attr_reader :side
  attr_writer :y


  def initialize(side,speed)
    @speed=speed
    @side=side
    @y=120
    @direction=nil
    if(side=='left')
      @x=20
    else
      @x=Window.width-40
    end
  end
  def move
    if @direction=='down'
      @y =[@y+@speed,Window.height-HEIGHT].min
    elsif @direction=='up'
      @y =[@y-@speed,0].max
    end

  end

  def draw
    @shape = Rectangle.new(x:@x,y:@y,width:PADDLE_WIDTH,height:HEIGHT,color: 'white')
  end

  def hit_ball?(ball)
    ball.shape &&[[ball.shape.x1, ball.shape.y1],[ball.shape.x2, ball.shape.y2],
                  [ball.shape.x3,ball.shape.y3],[ball.shape.x4,ball.shape.y4]].any? do |coordinates|
      @shape.contains?(coordinates[0],coordinates[1])
    end
  end
  def track_ball(ball_trajectory,frame)

    if frame+OPPONENT_DELAY<Window.frames
      if ball_trajectory.paddle_height!=nil
        if ball_trajectory.paddle_height > ball_height+8
          @y+=@speed
        elsif ball_trajectory.paddle_height < ball_height-8
          @y-=@speed
        end
      end
    end

  end
  def ball_height
    @y +(HEIGHT/2)
  end
  def y1
    @shape.y1
  end
end


class Ball
  HEIGHT_BALL=20
  attr_reader :shape
  attr_reader :x_middle
  attr_reader :y_middle
  attr_reader :x_speed
  attr_reader :y_speed

  def initialize(speed)
    @x=320
    @y=240
    @x_speed =-speed
    @y_speed =speed
    @speed=speed
  end
  def move
    if hit_bottom? || hit_top?
      @y_speed=-@y_speed
    end
    @x+=@x_speed
    @y+=@y_speed
  end
  def draw
    @shape =Square.new(x:@x,y: @y,size: HEIGHT_BALL,color:'white')
  end
  def hit_bottom?
    @y+HEIGHT_BALL>=Window.height
  end
  def hit_top?
    @y<=0
  end
  def bounce(paddle)
    if @last_side!=paddle.side
      position = ((@shape.y1 - paddle.y1) / HEIGHT.to_f)
      angle = position.clamp(0.2, 0.8) * Math::PI
      if paddle.side == 'left'
        @x_speed = Math.sin(angle) * @speed
        @y_speed = -Math.cos(angle) * @speed
      else
        @x_speed = -Math.sin(angle) * @speed
        @y_speed = -Math.cos(angle) * @speed
      end
      @last_side=paddle.side
    end
  end
  def ball_height
    @y
  end
  def bounds?
    @x<=0 || @x>=Window.width
  end
  def x_middle
    @x+(HEIGHT_BALL/2)
  end
  def y_middle
    @y+(HEIGHT_BALL/2)
  end
end



ball_velocity=10
player1 = Paddle.new('left',10)
opponent = Paddle.new('right',10)
ball=Ball.new(ball_velocity)
ball_trajectory=BallTrajectory.new(ball)
boom = Music.new('CLOUD UPDJ KIMERA.mp3')
loop =true
boom.play
divide = DivideLine.new

last_hit_frame=0
update do
  clear
  ball_trajectory.draw
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
    ball = Ball.new(ball_velocity)
    ball_trajectory=BallTrajectory.new(ball)
  end
  ball.move

  ball.draw

  opponent.track_ball(ball_trajectory,last_hit_frame)
  opponent.draw

end

on :key_down do |event|
  case event.key
  when 'down'
    player1.direction='down'
  when 'up'
    player1.direction='up'
  end
end

on :key_up do |event|
  player1.direction=nil

end

show
