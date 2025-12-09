extends ColorRect

@onready var animated_sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var black_flash: ColorRect = $"../BlackFlash"

var flash_mat := preload("res://shaders/white_shader_material.tres")


func impact_frame(sprite):
	
	var original = animated_sprite.material
	
	black_flash.visible = true
	animated_sprite.material = flash_mat
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	# Restore everything 
	black_flash.visible = false
	animated_sprite.material = original
