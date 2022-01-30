extends Control
const Line = preload("res://addons/saywhat_godot/dialogue_line.gd")
var logger = load("res://util/logger/logger.gd").new().get_logger("DialogueBox")

# Signals
signal typing_started(line)
signal dialogue_actioned(next_id)
signal typing_finished(line)

# Variables
var CurrentDialogueId = 0
var CurrentDialogueResource: DialogueResource = null
var line: Line
var PlayerActionDebouncer: bool
var ResponseSelectionIndex: int = 0
var ResponseSelectionDebouncer: bool 

func show_dialogue(id: String, resource: DialogueResource) -> void:
	logger.info("DialogueBox:%d - id: %s." % [self.get_instance_id(), id], "show_dialogue.")
	line = yield(DialogueManager.get_next_dialogue_line(id, resource), "completed")
	if line != null:
		handle(line)
	else:
		modulate.a = 0
		logger.info("DialogueBox:%d - id: Finished." % [self.get_instance_id()], "show_dialogue.")
		queue_free()

func handle(line: Line) -> void:
	var tween : Tween = $Tween
	var dialogue : RichTextLabel
	
	# Speech
	if line.responses.empty():
		dialogue = $DialogueWithoutResponses/Speech
		$DialogueWithoutResponses.visible = true
		$DialogueWithResponses.visible = false
	else:
		dialogue = $DialogueWithResponses/Speech
		$DialogueWithoutResponses.visible = false
		$DialogueWithResponses.visible = true
		for i in range(0, line.responses.size(), 1):
			var response = get_node("DialogueWithResponses/Response%d/Text" % (i))
			response.add_font_override("normal_font", load("res://UI/Monogram.tres"))
			response.text = line.responses[i].prompt
		ResponseSelectionIndex = 0
		ResponseSelectionDebouncer = true
		$DialogueWithResponses/Response0/Sprite.animation = "Show"
			
	
	dialogue.add_font_override("normal_font", load("res://UI/Monogram.tres"))
	dialogue.text = line.character + ": " + line.dialogue
	var selector_indx = 0
	yield(get_tree(), "idle_frame")
	
	modulate.a = 1
	
	#emit_signal("typing_started", line)
	
	tween.interpolate_property(dialogue, "percent_visible", 0, 1, dialogue.get_total_character_count() * 0.01)
	tween.start()
	yield(tween, "tween_all_completed")
	
	#emit_signal("typing_finished", line)
	
	yield(get_tree(), "idle_frame")
	next(line.next_id)

	
func next(next_id: String) -> void:
	emit_signal("dialogue_actioned", next_id)
	PlayerActionDebouncer = true

func increment_response_selector() -> void:
	if not line.responses.empty():
		ResponseSelectionDebouncer = false
		get_node("DialogueWithResponses/Response%d/Sprite" % (ResponseSelectionIndex)).animation = "Hide"
		ResponseSelectionIndex = (ResponseSelectionIndex + 1) % 4
		get_node("DialogueWithResponses/Response%d/Sprite" % (ResponseSelectionIndex)).animation = "Show"
		$Timer.start()
	
func decrement_response_selector() -> void:
	if not line.responses.empty():
		ResponseSelectionDebouncer = false
		get_node("DialogueWithResponses/Response%d/Sprite" % (ResponseSelectionIndex)).animation = "Hide"
		ResponseSelectionIndex = (ResponseSelectionIndex - 1) % 4 if ResponseSelectionIndex else 3 # Ternary
		get_node("DialogueWithResponses/Response%d/Sprite" % (ResponseSelectionIndex)).animation = "Show"
		$Timer.start()

func _on_Timer_timeout():
	ResponseSelectionDebouncer = true

func _ready():
	logger.info("DialogueBox:%d - Instanitated." % self.get_instance_id(), "_ready.")
	
	# Set Variable Defaults
	modulate.a = 0
	PlayerActionDebouncer = false
	GameState.IsInDialogueMode = true
	
func initialize(id: String, resource: DialogueResource) -> void:
	CurrentDialogueId = id
	CurrentDialogueResource = resource

func start() -> void:
	show_dialogue(CurrentDialogueId, CurrentDialogueResource)

func _exit_tree() -> void:
	GameState.IsInDialogueMode = false

func _process(delta):
	if GameState.IsInDialogueMode:
		if Input.is_action_pressed("movement_down") and ResponseSelectionDebouncer:
			increment_response_selector()
		elif Input.is_action_pressed("movement_up") and ResponseSelectionDebouncer:
			decrement_response_selector()
			
		if Input.is_action_just_pressed("action") and PlayerActionDebouncer:
			PlayerActionDebouncer = false
			if line.responses.empty():
				show_dialogue(line.next_id, CurrentDialogueResource)
			else:
				get_node("DialogueWithResponses/Response%d/Sprite" % (ResponseSelectionIndex)).animation = "Hide"
				show_dialogue(line.responses[ResponseSelectionIndex].next_id, CurrentDialogueResource)

