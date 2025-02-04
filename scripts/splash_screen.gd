class_name SplashScreen extends Control

@export var interval_time: float = 1.5
@export var fade_time: float = 1

signal finished()

func start():
	$Startup.play()
	
	modulate.a = 0
	
	show()
	
	var tween: Tween = create_tween()
	
	tween.connect("finished", finish)
	tween.tween_property(self, "modulate:a", 1, fade_time)
	tween.tween_interval(interval_time)
	tween.tween_property(self, "modulate:a", 0, fade_time)
	
func finish():
	print("FINISHED!")
	emit_signal("finished")
	queue_free()


func _on_startup_finished():
	$Bork.play()
