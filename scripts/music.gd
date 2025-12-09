extends AudioStreamPlayer2D

const tweentime = 0.6
var tween: Tween

func _ready() -> void:
	call_deferred("_setup")

func _setup():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.connect("primed_dash", Callable(self, "_on_primed_dash"))

func _process(_delta: float) -> void:
	pass

func _on_primed_dash():
	self.volume_db = 0
	await get_tree().create_timer(1.0).timeout
	self.volume_db = 0
