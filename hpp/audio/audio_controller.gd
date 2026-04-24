extends Node2D

@onready var music_player = $MusicPlayer

@export var mute: bool = false


@export var menu_music: AudioStream
@export var match_setup_music: AudioStream
@export var pregame_music: AudioStream
@export var battlefield_music: AudioStream
@export var game_over_music: AudioStream


# Make a stream and in each screen scene, call this function.
func play_music(stream: AudioStream):
	if mute:
		return
	if music_player.stream == stream:
		return

	music_player.stop()
	music_player.stream = stream
	music_player.play()
	
