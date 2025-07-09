extends StaticBody2D

# 砖块尺寸
@export var brick_width: float = 80.0
@export var brick_height: float = 30.0

# 砖块颜色（可以根据不同类型设置不同颜色）
@export var brick_color: Color = Color.GREEN

# 信号：砖块被销毁
signal brick_destroyed

func _ready():
	# 设置砖块外观
	var color_rect = $ColorRect
	color_rect.size = Vector2(brick_width, brick_height)
	color_rect.color = brick_color
	color_rect.position = Vector2(-brick_width/2, -brick_height/2)  # 居中
	
	# 设置碰撞形状
	var collision = $CollisionShape2D
	var shape = RectangleShape2D.new()
	shape.size = Vector2(brick_width, brick_height)
	collision.shape = shape

func hit_by_ball():
	# 被球击中时调用
	# 发出砖块被销毁的信号
	brick_destroyed.emit()
	
	# 播放销毁效果（可选）
	play_destroy_effect()
	
	# 销毁砖块
	queue_free()

func play_destroy_effect():
	# 简单的销毁效果：快速闪烁
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property($ColorRect, "modulate:a", 0.0, 0.05)
	tween.tween_property($ColorRect, "modulate:a", 1.0, 0.05)

func set_brick_color(color: Color):
	# 设置砖块颜色
	brick_color = color
	if has_node("ColorRect"):
		$ColorRect.color = color