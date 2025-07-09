extends CharacterBody2D

# 挡板移动速度
@export var speed: float = 400.0

# 挡板尺寸
@export var paddle_width: float = 100.0
@export var paddle_height: float = 20.0

# 游戏区域边界
var screen_size: Vector2

func _ready():
	# 获取屏幕尺寸
	screen_size = get_viewport().get_visible_rect().size
	
	# 设置挡板外观
	var color_rect = $ColorRect
	color_rect.size = Vector2(paddle_width, paddle_height)
	color_rect.color = Color.BLUE
	color_rect.position = Vector2(-paddle_width/2, -paddle_height/2)  # 居中
	
	# 设置碰撞形状
	var collision = $CollisionShape2D
	var shape = RectangleShape2D.new()
	shape.size = Vector2(paddle_width, paddle_height)
	collision.shape = shape
	
	# 设置初始位置
	position = Vector2(screen_size.x / 2, screen_size.y * 0.9)

func _physics_process(_delta):
	# 处理输入
	var input_direction = 0
	
	if Input.is_action_pressed("move_left"):
		input_direction -= 1
	if Input.is_action_pressed("move_right"):
		input_direction += 1
	
	# 设置速度
	velocity.x = input_direction * speed
	velocity.y = 0
	
	# 移动
	move_and_slide()
	
	# 限制挡板在屏幕边界内
	position.x = clamp(position.x, paddle_width/2, screen_size.x - paddle_width/2)