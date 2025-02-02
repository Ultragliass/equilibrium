extends TextureRect

@onready var settings_screen = preload("res://scenes/Settings_Screen.tscn")
@onready var start_game_button: Button = $StartGameButton
@onready var settings_button: Button = $SettingsButton

func _ready() -> void:
    _connect_signals()

func _connect_signals() -> void:
    start_game_button.connect("pressed", _on_start_game_button_pressed)
    settings_button.connect("pressed", _on_settings_button_pressed)

func _on_start_game_button_pressed() -> void:
    start_game_button.disabled = true
    var tween := create_tween()
    tween.tween_property(self, "modulate", Color(0, 0, 0, 0), 1)
    await tween.finished
    visible = false
    get_parent()._start_game()

func _on_settings_button_pressed() -> void:
    add_child(settings_screen.instantiate())