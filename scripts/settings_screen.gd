extends Panel

var sfx_bus_index: int = AudioServer.get_bus_index("SFX")
var music_bus_index: int = AudioServer.get_bus_index("Music")

@onready var settings_button: Button = $SettingsBackground/SettingsButton
@onready var sfx_volume_slider: HSlider = $SettingsBackground/SFXVolumeBox/SFXVolumeSlider
@onready var music_volume_slider: HSlider = $SettingsBackground/MusicVolumeBox/MusicVolumeSlider

func _ready() -> void:
    _initialize_volume_sliders()
    _connect_signals()

func _initialize_volume_sliders() -> void:
    sfx_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_index))
    music_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_index))

func _connect_signals() -> void:
    settings_button.connect("pressed", _close)
    sfx_volume_slider.connect("value_changed", _on_sfx_volume_changed)
    music_volume_slider.connect("value_changed", _on_music_volume_changed)

func _close() -> void:
    queue_free()

func _on_sfx_volume_changed(value: float) -> void:
    AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(value))

func _on_music_volume_changed(value: float) -> void:
    AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))