extends Control
@onready var compute: Button = %compute
@onready var gpu_particle_system: Button = %gpu_particle_system

@onready var cpu_particle_system: Button = %cpu_particle_system
@onready var image_manipulation: Button = %image_manipulation
@onready var multimesh: Button = %multimesh
@onready var sprites: Button = %sprites
@onready var quit: Button = %quit


const COMPUTE_DEMO = "res://compute/compute_demo.tscn"
const GPU_PART_DEMO = "res://gpu_particle_system/gpu_part_demo.tscn"
const PART_DEMO = "res://cpu_particle_system/part_demo.tscn"
const IMAGE_MANIPULATION_DEMO = "res://image_manipulation/image_manipulation_demo.tscn"
const MULTIMESH_DEMO ="res://multimesh/multimesh_demo.tscn"
const SPRITES_DEMO = "res://sprites/sprites_demo.tscn"


func _ready() -> void:
	compute.pressed.connect(change_scene.bind(COMPUTE_DEMO))
	gpu_particle_system.pressed.connect(change_scene.bind(GPU_PART_DEMO))
	cpu_particle_system.pressed.connect(change_scene.bind(PART_DEMO))
	image_manipulation.pressed.connect(change_scene.bind(IMAGE_MANIPULATION_DEMO))
	multimesh.pressed.connect(change_scene.bind(MULTIMESH_DEMO))
	sprites.pressed.connect(change_scene.bind(SPRITES_DEMO))
	quit.pressed.connect(get_tree().quit)
	


func change_scene(path:String) -> void:
	var packed_scene = load(path)
	get_tree().change_scene_to_packed(packed_scene)
