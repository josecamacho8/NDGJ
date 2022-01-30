extends Node2D

var logger = load("res://util/logger/logger.gd").new().get_logger("Level")
var DialogueBox = preload("res://UI/DialogueBox.tscn")

export var DialogueResource: Resource
export var StartingLine: String
export var OnLevelLoadStartTimerVal: float = 1.5


func _ready():
	logger.info("Level:%d - Instanitated." % self.get_instance_id(), "_ready.")
	yield(get_tree().create_timer(OnLevelLoadStartTimerVal), "timeout")
	if StartingLine != "" and DialogueResource != null:
		var dialogue = DialogueBox.instance()
		dialogue.initialize(StartingLine, DialogueResource)
		add_child(dialogue)
		dialogue.start()
