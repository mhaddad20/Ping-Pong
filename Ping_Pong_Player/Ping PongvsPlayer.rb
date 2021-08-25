require 'ruby2d'


set background: 'random'
set height: 420
set width: 440
set fps_cap: 60

NUM_LINES=10
HEIGHT = 150
OPPONENT_DELAY = 20
BALL_VELOCITY=6

class DivideLine
  def draw

    NUM_LINES.times do |x|
      Rectangle.new(x:(Window.width/2),y:(x*(Window.height/10)),width:Window.width/20,height:Window.height/20,color:'white')
    end
  end
end

class Paddle
  attr_writer :direction
  attr_reader :side


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
    @shape = Rectangle.new(x:@x,y:@y,width:20,height:HEIGHT,color: 'white')
  end

  def hit_ball?(ball)
    ball.shape &&[[ball.shape.x1, ball.shape.y1],[ball.shape.x2, ball.shape.y2],
                  [ball.shape.x3,ball.shape.y3],[ball.shape.x4,ball.shape.y4]].any? do |coordinates|
      @shape.contains?(coordinates[0],coordinates[1])
    end
  end

  def ball_height_player
    @y +(HEIGHT/2)
  end
  def ball_height_opponent
    @y +(HEIGHT/2)
  end
  def y1
    @shape.y1
  end
end


class Ball
  HEIGHT_BALL=20
  attr_reader :shape

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
      center_range = HEIGHT/100*5
      position = ((@shape.y1 - paddle.y1) / HEIGHT.to_f)
      angle = position.clamp(0.2, 0.8) * Math::PI
      if paddle.side == 'left'
        @x_speed = Math.sin(angle) * @speed
        @y_speed = -Math.cos(angle) * @speed
      else
        @x_speed = -Math.sin(angle) * @speed
        @y_speed = -Math.cos(angle) * @speed
      end
      if ball_height<paddle.ball_height_player-center_range ||ball_height>paddle.ball_height_player+center_range
        @speed+=1
        puts @speed
      else
        @speed=BALL_VELOCITY
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
    @x<=0 || @x>=Window.width
  end
end




player1 = Paddle.new('left',10)
opponent = Paddle.new('right',10)
ball=Ball.new(BALL_VELOCITY)
boom = Music.new('CLOUD UPDJ KIMERA.mp3')
loop =true
boom.play
divide = DivideLine.new

last_hit_frame=0
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

on :key_down do |event|
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

on :key_up do |event|
  player1.direction=nil
  opponent.direction =nil
end

show
