extends SpringArm3D

@export var mouse_sensitivity := 0.003

func _ready():
	# Klik di layar game untuk sembunyikan mouse, tekan ESC untuk munculkan lagi
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Putar Horizontal (Kiri-Kanan)
		rotation.y -= event.relative.x * mouse_sensitivity
		
		# Putar Vertikal (Atas-Bawah)
		rotation.x -= event.relative.y * mouse_sensitivity
		
		# Batasi agar kamera tidak muter balik (Clamp)
		rotation.x = clamp(rotation.x, deg_to_rad(-80), deg_to_rad(30))
