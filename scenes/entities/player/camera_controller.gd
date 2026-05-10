extends SpringArm3D

@export var mouse_sensitivity := 0.003

# Konfigurasi Zoom
@export var min_zoom := -0.5
@export var max_zoom := 2.5
@export var zoom_speed := 0.2

func _ready():
	spring_length = max_zoom
	# Sembunyikan kursor saat pertama kali game jalan
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# LOGIKA UNTUK MELEPAS KURSOR (Penting!)
	if event.is_action_pressed("ui_cancel"): # ui_cancel secara default adalah tombol ESC
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# LOGIKA UNTUK MENGUNCI KURSOR LAGI
	# Jika kamu klik kiri di layar game, kursor akan hilang lagi agar bisa kontrol kamera
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Logika Zoom dengan Scroll
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			spring_length -= zoom_speed
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			spring_length += zoom_speed
		spring_length = clamp(spring_length, min_zoom, max_zoom)

func _unhandled_input(event):
	# Logika Putar Kamera (Hanya jalan kalau kursor sedang terkunci)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation.x = clamp(rotation.x, deg_to_rad(-80), deg_to_rad(30))
