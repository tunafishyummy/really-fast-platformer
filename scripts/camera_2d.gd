extends Camera2D

const tween_time = 0.1

var cam_tween: Tween
var shake_time := 0.0
var shake_duration := 1.0
var shake_strength := 3.0
var lead_lerp
var base_offset
var player
var facing
var prime_camera_leading

func _ready() -> void:
	call_deferred("_connect_signals")

func _connect_signals():
	var p = get_tree().get_first_node_in_group("player")
	if p:
		p.connect("prime_started", Callable(self, "_on_prime_started"))
		p.connect("prime_stopped", Callable(self, "_on_prime_stopped"))
		p.connect("primed_dash", Callable(self, "_on_primed_dash"))

func _process(delta: float) -> void:
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	if prime_camera_leading:
		base_offset = Vector2(150 * player.facing, 0)
	elif player.running:
		base_offset = Vector2(100 * player.facing, 0)
	else:
		base_offset = Vector2(20 * player.facing, 0)

	if player.running:
		lead_lerp = 0.20
	else:
		lead_lerp = 0.02
	offset = offset.lerp(base_offset, lead_lerp)

	if shake_time > 0.0:
		shake_time -= delta
		var fade := shake_time / shake_duration
		offset += Vector2(
			randf_range(-shake_strength, shake_strength) * fade,
			randf_range(-shake_strength, shake_strength) * fade
		)

func _on_prime_started() -> void:
	prime_camera_leading = true
	cam_zoom_to(3.5)

func _on_prime_stopped() -> void:
	cam_zoom_to(4)
	position_smoothing_enabled = true
	prime_camera_leading = false

func _on_primed_dash() -> void:
	position_smoothing_enabled = false
	start_camera_shake()

func start_camera_shake() -> void:
	shake_time = shake_duration

func cam_zoom_to(target: float) -> void:
	var target_zoom := Vector2(target, target)
	if zoom.is_equal_approx(target_zoom):
		return

	if cam_tween and cam_tween.is_running():
		cam_tween.kill()

	cam_tween = get_tree().create_tween()
	cam_tween.tween_property(self, "zoom", target_zoom, tween_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
