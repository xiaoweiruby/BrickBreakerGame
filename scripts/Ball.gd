extends CharacterBody2D

# 球的移动速度
@export var speed: float = 300.0

# 球的方向向量
var direction: Vector2 = Vector2(1, -1).normalized()

# 游戏区域边界
var screen_size: Vector2
var ball_radius: float = 10.0

# 信号：球掉出屏幕底部
signal ball_lost

func _ready():
	# 获取屏幕尺寸
	screen_size = get_viewport().get_visible_rect().size
	
	# 设置球的外观
	var color_rect = $ColorRect
	color_rect.size = Vector2(ball_radius * 2, ball_radius * 2)
	color_rect.color = Color.RED
	color_rect.position = Vector2(-ball_radius, -ball_radius)  # 居中
	
	# 设置碰撞形状
	var collision = $CollisionShape2D
	var shape = CircleShape2D.new()
	shape.radius = ball_radius
	collision.shape = shape
	
	# 设置初始位置（屏幕中央偏下）
	position = Vector2(screen_size.x / 2, screen_size.y * 0.7)

func _physics_process(_delta):
	# 设置速度
	velocity = direction * speed
	
	# 移动并处理碰撞
	move_and_slide()
	
	# 处理碰撞反弹
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider:
			reflect_from_collision(collider)
	
	# 检查墙壁碰撞
	check_wall_collision()
	
	# 检查是否掉出屏幕底部
	if position.y > screen_size.y + ball_radius:
		ball_lost.emit()
		# 重置球的位置和方向
		reset_ball()

func check_wall_collision():
	# 左右墙壁碰撞
	if position.x <= ball_radius or position.x >= screen_size.x - ball_radius:
		direction.x = -direction.x
		position.x = clamp(position.x, ball_radius, screen_size.x - ball_radius)
	
	# 上墙碰撞
	if position.y <= ball_radius:
		direction.y = -direction.y
		position.y = ball_radius

# 移除这个函数，因为CharacterBody2D不使用body_entered信号

func reflect_from_collision(body):
	# 处理与其他物体的碰撞
	if body.has_method("hit_by_ball"):
		body.hit_by_ball()
	
	# 反弹逻辑
	if body.get_script() and body.get_script().get_path().get_file() == "Player.gd":
		# 与挡板碰撞时，根据击中位置调整反弹角度
		var hit_pos = (position.x - body.position.x) / (body.paddle_width / 2)
		hit_pos = clamp(hit_pos, -1.0, 1.0)
		direction = Vector2(hit_pos, -abs(direction.y)).normalized()
	else:
		# 与砖块碰撞时，简单垂直反弹
		direction.y = -direction.y

func reset_ball():
	# 重置球到初始位置
	position = Vector2(screen_size.x / 2, screen_size.y * 0.7)
	direction = Vector2(randf_range(-0.5, 0.5), -1).normalized()