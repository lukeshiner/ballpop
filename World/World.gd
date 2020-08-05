extends Node2D

onready var blocks = $Blocks
onready var restartTimer = $RestartTimer

func _process(_delta):
	if restartTimer.is_stopped() and len(blocks.get_used_cells()) == 0:
		print("Restarting...")
		restartTimer.start(1.5)

func _on_RestartTimer_timeout():
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
