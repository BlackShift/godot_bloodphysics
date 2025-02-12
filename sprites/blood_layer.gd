extends Node2D

const ONE_PIXEL_RED = preload("res://common/one_pixel_red.png")
@export var region:Rect2i
@export var border_color:Color
var spawning:bool = false
var blood_cells:Array[Vector2i]

@onready var fill_percent: Label = $"../Hud/PanelContainer2/VBoxContainer/fill_percent"
@onready var scale_slider: HSlider = $"../Hud/PanelContainer2/VBoxContainer/HBoxContainer/ScaleSlider"
@onready var scale_label: Label = $"../Hud/PanelContainer2/VBoxContainer/HBoxContainer/scale_label"
@onready var autofill: CheckButton = $"../Hud/PanelContainer2/VBoxContainer/autofill"
@onready var blood_scale:int = int(scale_slider.value)
@onready var region_size: Label = $"../Hud/PanelContainer2/VBoxContainer/region_size"
@onready var blood_count: Label = $"../Hud/PanelContainer2/VBoxContainer/blood_count"
@onready var clear: Button = $"../Hud/PanelContainer2/VBoxContainer/Clear"

var autofill_last_position:Vector2i


func _ready() -> void:
	scale_slider.drag_ended.connect(on_scale_changed)
	scale_slider.value_changed.connect(scale_label_update)
	region_size.text = "%sx%s" % [region.size.x/blood_scale,region.size.y/blood_scale]
	clear.pressed.connect(on_scale_changed.bind(true))

func scale_label_update(value:float):
	scale_label.text = String.num(value,0)

func on_scale_changed(changed:bool):
	if changed:
		for c in get_children():
			c.queue_free()
			blood_cells.clear()
		blood_scale = int(scale_slider.value)
		autofill_last_position = Vector2i.ZERO
		region_size.text = "%sx%s" % [region.size.x/blood_scale,region.size.y/blood_scale]
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			spawning = event.pressed

func _process(delta: float) -> void:
	if spawning:
		spawn_blood(get_local_mouse_position())
	if autofill.button_pressed:
		spawn_blood(Vector2(autofill_last_position * blood_scale)  + Vector2(region.position))
		autofill_last_position.x += 1
		if autofill_last_position.x >= region.size.x / blood_scale:
			autofill_last_position.x = 0
			autofill_last_position.y += 1
			if autofill_last_position.y >= region.size.y / blood_scale:
				autofill.button_pressed = false
		
	update_stats()

func spawn_blood(pos:Vector2) -> void:
	var region_position = Vector2i(pos.round()) - region.position
	var cell_position = region_position / blood_scale
	if not blood_cells.has(cell_position) and region.has_point(pos):
		var sprite = Sprite2D.new()
		sprite.texture = ONE_PIXEL_RED
		sprite.scale = Vector2(blood_scale,blood_scale)
		sprite.centered = false
		add_child(sprite)
		sprite.position = pos
		blood_cells.append(cell_position)
	
func update_stats() -> void:
	var max_size := (region.size.x * region.size.y) / (blood_scale * blood_scale)
	var fill = float(blood_cells.size()) / float(max_size)
	fill_percent.text = "Blood Fill: " + String.num(fill*100,0) + "%"
	blood_count.text = "Sprites: " + String.num(get_child_count())

func _draw() -> void:
	draw_rect(region.grow(3),Color.BLUE,false,3)
