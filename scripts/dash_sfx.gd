extends AudioStreamPlayer2D

func _ready():
	call_deferred("_setup")

func _setup():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.connect("primed_dash", Callable(self, "_on_primed_dash"))

func _on_primed_dash():
	play()
