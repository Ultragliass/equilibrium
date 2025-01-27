extends Panel

@onready var settings_button: Button = $SettingsBackground/SettingsButton
@onready var sfx_volume_slider: HSlider = $SettingsBackground/SFXVolumeBox/SFXVolumeSlider
@onready var music_volume_slider: HSlider = $SettingsBackground/MusicVolumeBox/MusicVolumeSlider

func _ready():
	sfx_volume_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	music_volume_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	settings_button.connect("pressed", _close)
	sfx_volume_slider.connect("value_changed", _on_sfx_volume_changed)
	music_volume_slider.connect("value_changed", _on_music_volume_changed)
	

func _close():
	queue_free()

func _on_sfx_volume_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)

func _on_music_volume_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)