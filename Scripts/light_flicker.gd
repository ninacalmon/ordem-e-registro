extends PointLight2D

@export var first_flicker_interval_min: int
@export var first_flicker_interval_max: int
@export var flicker_interval_min: int
@export var flicker_interval_max: int

@onready var sound_effects_bus_name = Global.AUDIO_BUS_DIC[Global.AudioBus.SOUND_EFFECTS]
@onready var original_energy = self.energy

var timer: Timer
var audio_stream_player: AudioStreamPlayer
var electric_sound: AudioStream  = preload("res://Sounds/buzz.ogg")

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = randi_range(first_flicker_interval_min, first_flicker_interval_max)
	audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.bus = sound_effects_bus_name
	audio_stream_player.stream = electric_sound
	self.add_child(timer)
	self.add_child(audio_stream_player)
	timer.timeout.connect(flicker)
	timer.start()

func flicker():
	timer.stop()
	audio_stream_player.volume_db = randf_range(-30, -28)
	audio_stream_player.pitch_scale = randf_range(1.8, 2.4)
	audio_stream_player.play()
	self.energy = 0
	var flicker_tween = get_tree().create_tween()
	flicker_tween.tween_property(self, "energy", original_energy, 0.2)
	await flicker_tween.finished
	self.energy = 0

	await get_tree().create_timer(0.1).timeout
	self.energy = original_energy
	timer.start(randi_range(flicker_interval_min, flicker_interval_max))
