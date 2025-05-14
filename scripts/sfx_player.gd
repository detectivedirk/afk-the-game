extends AudioStreamPlayer3D

const PITCH_SCALING: float = 0.1
const PITCH_MAX: float = 2

@onready var pitch_timer = $timer

var active_pitch = 1

func _ready():
	self.stream = AudioStreamPolyphonic.new()

@rpc ("any_peer", "call_local")
func play_sound_multiplayer(sound: String):
	var audio_stream = load("res://sounds/%s.ogg" % sound)
	
	if !playing: play()
	
	var polyphonic_stream_playback := self.get_stream_playback()
	var _current_stream = polyphonic_stream_playback.play_stream(audio_stream)

func play_sound_random_pitch(sound: String, variance: float):
	var audio_stream = load("res://sounds/%s.ogg" % sound)
	
	if !playing: play()
	
	var polyphonic_stream_playback := self.get_stream_playback()
	var current_stream = polyphonic_stream_playback.play_stream(audio_stream)
	
	var random_pitch = randf_range(-variance, variance)
	polyphonic_stream_playback.set_stream_pitch_scale(current_stream, 1 + random_pitch)

func play_shepard_tone(sound: String):
	var audio_stream = load("res://sounds/%s.ogg" % sound)
	
	if !playing: play()
	
	var polyphonic_stream_playback := self.get_stream_playback()
	var current_stream = polyphonic_stream_playback.play_stream(audio_stream)
	
	active_pitch = min(PITCH_MAX, active_pitch + PITCH_SCALING)
	
	polyphonic_stream_playback.set_stream_pitch_scale(current_stream, active_pitch)
	pitch_timer.start(0.25)

func _on_timer_timeout() -> void:
	active_pitch = 1
