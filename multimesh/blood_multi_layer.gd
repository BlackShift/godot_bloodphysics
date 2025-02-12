extends Node2D

@export var region:Rect2i

@onready var blood_multi: MultiMeshInstance2D = $BloodMulti
@onready var visible_label: Label = $"../Hud/PanelContainer2/MarginContainer/VBoxContainer/HBoxContainer/visible_label"
@onready var max_inst_label: Label = $"../Hud/PanelContainer2/MarginContainer/VBoxContainer/HBoxContainer2/max_inst_label"
@onready var autofill: CheckButton = $"../Hud/PanelContainer2/MarginContainer/VBoxContainer/autofill"
@onready var check_button: CheckButton = $"../Hud/PanelContainer2/MarginContainer/VBoxContainer/CheckButton"

const ONE_PIXEL_RED = preload("res://common/one_pixel_red.png")

var placed_instances:Array[Vector2i]

func _ready() -> void:
	blood_multi.multimesh.visible_instance_count = -1
	blood_multi.multimesh.instance_count = region.size.x * region.size.y
	set_mesh(Vector2(1,1))
	update_stats()
	
func update_stats() -> void:
	max_inst_label.text = String.num(blood_multi.multimesh.instance_count)
	visible_label.text = String.num(blood_multi.multimesh.visible_instance_count)
	pass

func set_mesh(size:Vector2) -> void:
	var mesh = PlaneMesh.new()
	mesh.size = size
	mesh.orientation = PlaneMesh.FACE_Z
	blood_multi.multimesh.mesh = mesh
	blood_multi.texture = ONE_PIXEL_RED

func _draw() -> void:
	draw_rect(region.grow(3),Color.BLUE,false,3)

var mouse_spawning := false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_spawning = event.pressed

var autofill_last_position:Vector2

func _process(delta: float) -> void:
	if mouse_spawning:
		spawn_blood(blood_multi.get_local_mouse_position())
	if autofill.button_pressed:
		spawn_blood(Vector2(autofill_last_position)  + Vector2(region.position))
		autofill_last_position.x += 1
		if autofill_last_position.x >= region.size.x:
			autofill_last_position.x = 0
			autofill_last_position.y += 1
			if autofill_last_position.y >= region.size.y:
				autofill.button_pressed = false
	update_stats()
	pass

func spawn_blood(pos:Vector2) -> void:
	var cell_pos = Vector2i(pos)
	var optional_condition:bool = false if not check_button.button_pressed else placed_instances.has(cell_pos)
	if not optional_condition and region.has_point(Vector2i(pos)):
		#blood_multi.multimesh.visible_instance_count += 1
		var instance_id = placed_instances.size()
		var instance_transform:Transform2D = Transform2D(0.0,pos)
		blood_multi.multimesh.set_instance_transform_2d(instance_id,instance_transform)
		placed_instances.append(cell_pos)
