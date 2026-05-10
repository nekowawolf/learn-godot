extends CharacterBody3D

const RUN_SPEED = 6.0
const WALK_SPEED = 3.0
const JUMP_VELOCITY = 5.2
const GRAVITY_MULTIPLIER = 1.5

@onready var camera_node := $CameraController/Camera3D
var animation_player: AnimationPlayer
var character_visual: Node3D
var direction := Vector3.ZERO
var is_jumping := false

func _ready():
	# Mencari Model & AnimationPlayer secara otomatis
	for child in get_children():
		if child is Node3D and child.has_node("AnimationPlayer"):
			character_visual = child
			animation_player = child.get_node("AnimationPlayer")
			break
	
	if not character_visual:
		character_visual = get_node_or_null("Idle")
		if character_visual:
			animation_player = character_visual.get_node_or_null("AnimationPlayer")

func _physics_process(delta: float) -> void:
	# 1. Gravitasi
	if not is_on_floor():
		velocity += get_gravity() * GRAVITY_MULTIPLIER * delta
	else:
		is_jumping = false

	# 2. Handle Loncat
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		# Langsung mainkan animasi lompat dan skip bagian awal yang delay
		if animation_player and animation_player.has_animation("jump"):
			animation_player.play("jump")
			animation_player.seek(0.57, true) # SKIP ke detik 0.57

	# 3. Input Arah
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	if camera_node:
		var look_direction = camera_node.global_transform.basis
		direction = (look_direction.z * input_dir.y + look_direction.x * input_dir.x).normalized()
		direction.y = 0 

		var current_speed = RUN_SPEED
		if Input.is_action_pressed("sprint"):
			current_speed = WALK_SPEED

		if direction != Vector3.ZERO:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
			
			if character_visual:
				var target_angle = atan2(direction.x, direction.z)
				character_visual.rotation.y = lerp_angle(character_visual.rotation.y, target_angle, 0.2)
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
	update_animations()

func update_animations():
	if not animation_player: return

	# Jika sedang di udara, biarkan animasi jump berjalan
	if not is_on_floor() or is_jumping:
		# Jangan gunakan play_if_exists di sini agar tidak kena reset/blend terus menerus
		if animation_player.current_animation != "jump":
			animation_player.play("jump")
		return 

	# Jika di tanah
	if direction != Vector3.ZERO:
		if Input.is_action_pressed("sprint"):
			play_if_exists("walk")
		else:
			play_if_exists("run")
	else:
		play_if_exists("idle")

func play_if_exists(anim_name: String):
	if animation_player.has_animation(anim_name):
		if animation_player.current_animation != anim_name:
			# Gunakan blend time 0.1 agar transisi tidak terlalu lambat
			animation_player.play(anim_name, 0.1)
