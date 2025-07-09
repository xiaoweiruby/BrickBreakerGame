extends Node2D

# 预加载场景
var player_scene = preload("res://scenes/Player.tscn")
var ball_scene = preload("res://scenes/Ball.tscn")
var brick_scene = preload("res://scenes/Brick.tscn")

# 游戏对象引用
var player: CharacterBody2D
var ball: CharacterBody2D
var bricks: Array = []

# 游戏状态
var game_state: String = "playing"  # playing, game_over, victory
var lives: int = 3
var score: int = 0
var total_bricks: int = 0

# UI元素
var ui_layer: CanvasLayer
var score_label: Label
var lives_label: Label
var game_over_label: Label
var victory_label: Label
var restart_label: Label

# 砖块布局参数
var brick_rows: int = 5
var brick_cols: int = 10
var brick_spacing: float = 5.0
var brick_start_y: float = 100.0

# 屏幕尺寸
var screen_size: Vector2

# 胜利礼花效果
var fireworks_particles: Array = []

func _ready():
	# 获取屏幕尺寸
	screen_size = get_viewport().get_visible_rect().size
	
	# 创建UI层
	setup_ui()
	
	# 初始化游戏
	start_new_game()

func setup_ui():
	# 创建UI层
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	
	# 分数标签
	score_label = Label.new()
	score_label.position = Vector2(20, 20)
	score_label.add_theme_font_size_override("font_size", 24)
	score_label.text = "Score: 0"
	ui_layer.add_child(score_label)
	
	# 生命标签
	lives_label = Label.new()
	lives_label.position = Vector2(20, 50)
	lives_label.add_theme_font_size_override("font_size", 24)
	lives_label.text = "Lives: 3"
	ui_layer.add_child(lives_label)
	
	# 游戏结束标签
	game_over_label = Label.new()
	game_over_label.position = Vector2(screen_size.x/2 - 100, screen_size.y/2 - 50)
	game_over_label.add_theme_font_size_override("font_size", 36)
	game_over_label.add_theme_color_override("font_color", Color.RED)
	game_over_label.text = "GAME OVER"
	game_over_label.visible = false
	ui_layer.add_child(game_over_label)
	
	# 胜利标签
	victory_label = Label.new()
	victory_label.position = Vector2(screen_size.x/2 - 80, screen_size.y/2 - 50)
	victory_label.add_theme_font_size_override("font_size", 36)
	victory_label.add_theme_color_override("font_color", Color.GOLD)
	victory_label.text = "VICTORY!"
	victory_label.visible = false
	ui_layer.add_child(victory_label)
	
	# 重新开始提示
	restart_label = Label.new()
	restart_label.position = Vector2(screen_size.x/2 - 120, screen_size.y/2)
	restart_label.add_theme_font_size_override("font_size", 18)
	restart_label.text = "Press SPACE to restart"
	restart_label.visible = false
	ui_layer.add_child(restart_label)

func start_new_game():
	# 重置游戏状态
	game_state = "playing"
	lives = 3
	score = 0
	
	# 清理现有对象
	clear_game_objects()
	
	# 创建玩家
	create_player()
	
	# 创建球
	create_ball()
	
	# 创建砖块
	create_bricks()
	
	# 更新UI
	update_ui()
	
	# 隐藏游戏结束UI
	game_over_label.visible = false
	victory_label.visible = false
	restart_label.visible = false

func clear_game_objects():
	# 清理现有游戏对象
	if player:
		player.queue_free()
	if ball:
		ball.queue_free()
	
	# 清理砖块
	for brick in bricks:
		if is_instance_valid(brick):
			brick.queue_free()
	bricks.clear()
	
	# 清理礼花效果
	for particle in fireworks_particles:
		if is_instance_valid(particle):
			particle.queue_free()
	fireworks_particles.clear()

func create_player():
	# 创建玩家挡板
	player = player_scene.instantiate()
	add_child(player)

func create_ball():
	# 创建球
	ball = ball_scene.instantiate()
	add_child(ball)
	
	# 连接球丢失信号
	ball.ball_lost.connect(_on_ball_lost)

func create_bricks():
	# 计算砖块布局
	var brick_width = 80.0
	var brick_height = 30.0
	var total_width = brick_cols * brick_width + (brick_cols - 1) * brick_spacing
	var start_x = (screen_size.x - total_width) / 2 + brick_width / 2
	
	# 创建砖块网格
	for row in range(brick_rows):
		for col in range(brick_cols):
			var brick = brick_scene.instantiate()
			
			# 设置砖块位置
			var x = start_x + col * (brick_width + brick_spacing)
			var y = brick_start_y + row * (brick_height + brick_spacing)
			brick.position = Vector2(x, y)
			
			# 设置砖块颜色（根据行数变化）
			var colors = [Color.RED, Color.ORANGE, Color.YELLOW, Color.GREEN, Color.BLUE]
			brick.set_brick_color(colors[row % colors.size()])
			
			# 连接砖块销毁信号
			brick.brick_destroyed.connect(_on_brick_destroyed)
			
			add_child(brick)
			bricks.append(brick)
	
	total_bricks = bricks.size()

func _on_ball_lost():
	# 球丢失处理
	lives -= 1
	update_ui()
	
	if lives <= 0:
		game_over()

func _on_brick_destroyed():
	# 砖块被销毁处理
	score += 10
	update_ui()
	
	# 检查胜利条件
	var remaining_bricks = 0
	for brick in bricks:
		if is_instance_valid(brick):
			remaining_bricks += 1
	
	if remaining_bricks == 0:
		victory()

func game_over():
	# 游戏结束
	game_state = "game_over"
	game_over_label.visible = true
	restart_label.visible = true

func victory():
	# 胜利
	game_state = "victory"
	victory_label.visible = true
	restart_label.visible = true
	
	# 播放胜利礼花效果
	play_victory_fireworks()

func play_victory_fireworks():
	# 创建简单的礼花效果
	for i in range(5):
		var firework = create_firework_particle()
		firework.position = Vector2(
			randf_range(100, screen_size.x - 100),
			randf_range(100, screen_size.y - 200)
		)
		add_child(firework)
		fireworks_particles.append(firework)
		
		# 延迟创建更多礼花
		get_tree().create_timer(i * 0.3).timeout.connect(func(): create_delayed_firework())

func create_firework_particle() -> Node2D:
	# 创建礼花粒子效果
	var firework = Node2D.new()
	
	# 创建多个彩色小方块作为粒子
	for i in range(20):
		var particle = ColorRect.new()
		particle.size = Vector2(4, 4)
		particle.color = Color(
			randf_range(0.5, 1.0),
			randf_range(0.5, 1.0),
			randf_range(0.5, 1.0)
		)
		particle.position = Vector2.ZERO
		firework.add_child(particle)
		
		# 粒子动画
		var tween = create_tween()
		var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var distance = randf_range(50, 150)
		tween.parallel().tween_property(particle, "position", direction * distance, 2.0)
		tween.parallel().tween_property(particle, "modulate:a", 0.0, 2.0)
	
	return firework

func create_delayed_firework():
	# 延迟创建的礼花
	if game_state == "victory":
		var firework = create_firework_particle()
		firework.position = Vector2(
			randf_range(100, screen_size.x - 100),
			randf_range(100, screen_size.y - 200)
		)
		add_child(firework)
		fireworks_particles.append(firework)

func update_ui():
	# 更新UI显示
	score_label.text = "Score: " + str(score)
	lives_label.text = "Lives: " + str(lives)

func _input(event):
	# 处理输入
	if event.is_action_pressed("ui_accept"):  # 空格键
		if game_state == "game_over" or game_state == "victory":
			start_new_game()