extends Sprite

var current_direction : String = 'none'
var orig_texture : Texture

# This is a neat idea from willnationsdev:
# https://www.reddit.com/r/godot/comments/9klj57/comment/e709iwt/?utm_source=reddit&utm_medium=web2x&context=3
export(Texture) var north_pickup_tex
export(Texture) var south_pickup_tex
export(Texture) var east_pickup_tex
export(Texture) var west_pickup_tex

export(Texture) var north_dropoff_tex
export(Texture) var south_dropoff_tex
export(Texture) var east_dropoff_tex
export(Texture) var west_dropoff_tex

var type_tex_map : Dictionary

func _ready():
	type_tex_map = {
		'pickup': {
			'north': north_pickup_tex,
			'south': south_pickup_tex,
			'east': east_pickup_tex,
			'west': west_pickup_tex
		},
		'dropoff': {
			'north': north_dropoff_tex,
			'south': south_dropoff_tex,
			'east': east_dropoff_tex,
			'west': west_dropoff_tex
		}
	}
	self.orig_texture = texture

func on_compass_update(direction : String, type: String):
	self.texture = type_tex_map[type][direction]
