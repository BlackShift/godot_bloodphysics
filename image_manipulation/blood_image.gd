extends Sprite2D
@export var size:Vector2

@onready var autofill: CheckButton = $"../Hud/PanelContainer2/MarginContainer/VBoxContainer/AutoFill"
@onready var texture_format: OptionButton = $"../Hud/PanelContainer2/MarginContainer/VBoxContainer/texture_format"

enum AVILABLE_FORMATS { 
	FORMAT_R8 = Image.FORMAT_R8,
	FORMAT_RF = Image.FORMAT_RF,
	FORMAT_RG8 = Image.FORMAT_RG8,
	FORMAT_RGB8 = Image.FORMAT_RGB8,
	FORMAT_RGB565 = Image.FORMAT_RGB565,
	FORMAT_RGBA8 = Image.FORMAT_RGBA8,
	FORMAT_RGBA4444 = Image.FORMAT_RGBA4444,
	FORMAT_RGBAF = Image.FORMAT_RGBAF,
	FORMAT_RGBAH = Image.FORMAT_RGBAH,
	FORMAT_RGBE9995 = Image.FORMAT_RGBE9995,
	FORMAT_RGBF = Image.FORMAT_RGBF,
	FORMAT_RGBH = Image.FORMAT_RGBH
}



var img:Image
var region:Rect2i
func _ready() -> void:
	region.size = Vector2i(size)
	for k in AVILABLE_FORMATS.keys():
		texture_format.add_item(k)
	texture_format.item_selected.connect(texture_format_selected)
	texture_format.selected = 0
	texture_format_selected(0)

func texture_format_selected(index:int) -> void:
	var key = AVILABLE_FORMATS.keys()[index]
	var image_format = AVILABLE_FORMATS[key]
	img = Image.create_empty(size.x,size.y,false,image_format)
	texture = ImageTexture.create_from_image(img)
	autofill_last_position = Vector2.ZERO
	
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,img.get_size()),Color.BLUE,false,3)

var mouse_spawning := false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_spawning = event.pressed

var autofill_last_position:Vector2

func _process(delta: float) -> void:
	if mouse_spawning:
		spawn_blood(get_local_mouse_position())
	if autofill.button_pressed:
		spawn_blood(Vector2(autofill_last_position)  + Vector2(region.position))
		autofill_last_position.x += 1
		if autofill_last_position.x >= region.size.x:
			autofill_last_position.x = 0
			autofill_last_position.y += 1
			if autofill_last_position.y >= region.size.y:
				autofill.button_pressed = false
	pass

func spawn_blood(pos:Vector2) -> void:
	var cell_pos = Vector2i(pos)
	if region.has_point(Vector2i(pos)):
		#blood_multi.multimesh.visible_instance_count += 1
		img.set_pixel(cell_pos.x,cell_pos.y,Color.RED)
	(texture as ImageTexture).update(img)
