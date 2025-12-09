extends AudioStreamPlayer2D

func _ready():
	call_deferred("_setup")

func _setup():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.connect("prime_started", Callable(self, "_on_prime_started"))

func _on_prime_started():
	play()
