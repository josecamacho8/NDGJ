extends KinematicBody2D

var logger = load("res://util/logger/logger.gd").new().get_logger("Player2D")
var DialogueBox = preload("res://UI/DialogueBox.tscn")

# 2D
var overlappingArea = null
var velocity = Vector2(0, 0)
export var speed = 50

func interact_with_object() -> void: # What to do when the action button is pressed
	logger.info("Starting interaction with object: %s" % overlappingArea.get_rid().get_id(), "interact_with_object")
	var dialogue = DialogueBox.instance()
	dialogue.initialize(overlappingArea.owner.StartingLine, overlappingArea.owner.DialogueResource)
	add_child(dialogue)
	dialogue.start()
	
func overlap_area_with_valid_dialogue() -> bool:
	return overlappingArea and overlappingArea.owner.StartingLine != "" and overlappingArea.owner.DialogueResource != null

func _physics_process(delta) -> void:
	if not GameState.IsInDialogueMode:
		if Input.is_action_just_pressed("action") and overlap_area_with_valid_dialogue():
			GameState.IsInDialogueMode = true
			interact_with_object()
		else:
			var left = -int(Input.is_action_pressed("movement_left"))
			var right = int(Input.is_action_pressed("movement_right"))
			var up = -int(Input.is_action_pressed("movement_up"))
			var down = int(Input.is_action_pressed("movement_down"))
			
			velocity.x = (left + right) * speed
			velocity.y = (up + down) * speed
			
			# Do animation logic
			if velocity.x < 0:
				$AnimatedSprite.set_animation("Walk_Left")
			elif velocity.x > 0:
				$AnimatedSprite.set_animation("Walk_Right")
			else:
				if velocity.y < 0:
					$AnimatedSprite.set_animation("Walk_Up")
				elif velocity.y > 0:
					$AnimatedSprite.set_animation("Walk_Down")
				else:
					$AnimatedSprite.set_animation("Idle_Down")
			var collide = move_and_collide(velocity * delta) # Move based on current velocity

func _on_Area2D_area_entered(area) -> void:
	logger.info("Area2D:%d." % area.get_rid().get_id(), "_on_Area2D_area_entered")
	if area.owner.name == "SceneTransition":
		area.owner.transition()
	overlappingArea = area
	
func _on_Area2D_area_exited(area) -> void:
	logger.info("Area2D:%d." % area.get_rid().get_id(), "_on_Area2D_area_exited")
	overlappingArea = null
