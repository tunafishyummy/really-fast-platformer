extends CharacterBody2D

signal prime_started
signal prime_stopped
signal primed_dash

const WALK_SPEED = 40
const RUN_SPEED = 200

const WALK_JUMP = 0
const RUN_JUMP = -400

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var black_flash: ColorRect = $BlackFlash
@onready var impact: ColorRect = $BlackFlash
@onready var coyote_timer: Timer = $CoyoteTimer

var running := false
var priming := false
var prime_on_cooldown := false
var prime_cooldown_time := 0
var done_coiling := false
var facing := 1
var jumped_this_frame := false


func _ready():
	add_to_group("player")

func _physics_process(delta):
	
	jumped_this_frame = false
	
	running = Input.is_action_pressed("run")
	prime_logic()
	
	if running:
		run_logic(delta)
	else:
		walk_logic(delta)

	handle_animations()
	
	var was_on_floor := is_on_floor()
	
	move_and_slide()
	
	coyote_time(was_on_floor)

# ---- PRIME LOGIC ----

func prime_logic():
	if Input.is_action_just_pressed("prime") and not prime_on_cooldown:
		priming = true
		emit_signal("prime_started")

	if Input.is_action_just_released("prime"):
		stop_prime()

	# Dash
	if priming and Input.is_action_just_pressed("primedash"):
		emit_signal("primed_dash")
		impact.impact_frame(self)


		var impact = get_tree().get_first_node_in_group("impact_layer")
		if impact:
			impact.impact_frame(animated_sprite)

		position.x += 200 * facing
		stop_prime()

func stop_prime():
	priming = false
	emit_signal("prime_stopped")
	start_prime_cooldown()

func start_prime_cooldown():
	prime_on_cooldown = true
	await get_tree().create_timer(prime_cooldown_time).timeout
	prime_on_cooldown = false

# ---- MOVEMENT ----

func walk_logic(delta):
	var direction = Input.get_axis("wasd_a","wasd_d")
	jump_and_gravity(delta, WALK_JUMP)
	move_x(WALK_SPEED)

func run_logic(delta):
	var direction = Input.get_axis("wasd_a","wasd_d")
	jump_and_gravity(delta, RUN_JUMP)
	move_x(RUN_SPEED)

func jump_and_gravity(delta, jump):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and (is_on_floor() or not coyote_timer.is_stopped()):
		velocity.y = jump
		coyote_timer.stop
		jumped_this_frame = true
	if Input.is_action_just_released("jump") and not is_on_floor():
		velocity.y = velocity.y/1.7

func move_x(speed):
	var direction = Input.get_axis("wasd_a","wasd_d")

	if direction:
		velocity.x = direction * speed
		facing = sign(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
# ---- MOVEMENT POLISH ----

func coyote_time(was_on_floor):
	if was_on_floor and not is_on_floor() and not jumped_this_frame:
		coyote_timer.start()

# ---- ANIMATIONS ----

func handle_animations():
	var direction = Input.get_axis("wasd_a","wasd_d")
	
	if direction > 0:
		animated_sprite.flip_h = false
		facing = 1
	elif direction < 0:
		animated_sprite.flip_h = true
		facing = -1

	if priming:
		if not is_on_floor() and velocity.y < 0:
			animated_sprite.play("jumppriming")
			if animated_sprite.frame == 2:
				animated_sprite.frame = 2
		elif not is_on_floor() and velocity.y > 0:
			animated_sprite.play("fallpriming")
			if animated_sprite.frame == 2:
				animated_sprite.frame = 2
		else:
			if running and direction != 0:
				animated_sprite.play("runpriming")
			elif running:
				animated_sprite.play("run_idlepriming")
			elif direction != 0:
				animated_sprite.play("walkpriming")
			elif direction == 0:
				animated_sprite.play("idlepriming")
	else:
		if not is_on_floor() and velocity.y < 0:
			animated_sprite.play("jump")
			if animated_sprite.frame == 2:
				animated_sprite.frame = 2
		elif not is_on_floor() and velocity.y > 0:
			animated_sprite.play("fall")
			if animated_sprite.frame == 2:
				animated_sprite.frame = 2
		else:
			if running and direction != 0:
				animated_sprite.play("run")
			elif running and direction == 0:
				animated_sprite.play("run_idle")
			elif direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("walk")
