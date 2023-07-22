extends Sprite

var current_direction : String = 'none'
var orig_texture : Texture

# This is a neat idea from willnationsdev:
# https://www.reddit.com/r/godot/comments/9klj57/comment/e709iwt/?utm_source=reddit&utm_medium=web2x&context=3
export(Texture) var north_tex
export(Texture) var south_tex
export(Texture) var east_tex
export(Texture) var west_tex

func _ready():
	self.orig_texture = texture

func on_compass_update(direction : String):
	# This is … fine.
	match direction:
		'north':
			self.texture = north_tex
		'south':
			self.texture = south_tex
		'east':
			self.texture = east_tex
		'west':
			self.texture = west_tex
		_:
			self.texture = self.orig_texture
