extends Node2D

const BLOOD_COMPUTE_BLIT = preload("res://compute/blood_compute_blit.glsl")
const BLOOD_COMPUTE_DECAY = preload("res://compute/blood_compute_decay.glsl")

@onready var blood_sprite: Sprite2D = $blood_sprite
@export var blit_texture:Texture2D
@onready var decay_timer: Timer = $DecayTimer
@onready var autofill: CheckButton = %autofill

var decay_pipeline:RID
var blit_pipeline:RID
var blood_map_uniform_set:RID
var blit_texture_uniform_set:RID
var position_buffer:RID
var position_buffer_set:RID
var rd:RenderingDevice
var map_texture:RID
var width:int
var height:int

class blit_data extends RefCounted:
	var src:Vector2i
	var dst:Vector2i
	func toByteArray() -> PackedByteArray:
		var arr = PackedInt32Array()
		arr.resize(4)
		arr.set(0,src.x)
		arr.set(1,src.y)
		arr.set(2,dst.x)
		arr.set(3,dst.y)
		return arr.to_byte_array()


func _ready() -> void:
	
	#Use the placeholder texture for sizing
	height = blood_sprite.texture.get_height()
	width = blood_sprite.texture.get_width()
	
	rd = RenderingServer.get_rendering_device()
	var texture_format := RDTextureFormat.new()
	
	texture_format.format = RenderingDevice.DATA_FORMAT_R32_SFLOAT
	texture_format.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	texture_format.height = height
	texture_format.width = width
	texture_format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | \
								 RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | \
								 RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT
	map_texture = rd.texture_create(texture_format,RDTextureView.new());
	rd.texture_clear(map_texture,Color.RED,0,1,0,1)
	
	var blood_map_uniform = RDUniform.new()
	blood_map_uniform.binding = 0
	blood_map_uniform.add_id(map_texture)
	
	
	
	#All textures are set up now to set up the pipeline, we will create 2 pipelines
	# one for decay and the other for blitting
	
	
	#region DECAY
	var decay_shader_spirv := BLOOD_COMPUTE_DECAY.get_spirv() # not actually needed but ugh godot
	var decay_shader_rd := rd.shader_create_from_spirv(decay_shader_spirv,"BloodDecay")
	blood_map_uniform_set = rd.uniform_set_create([blood_map_uniform],decay_shader_rd,0)
	decay_pipeline = rd.compute_pipeline_create(decay_shader_rd)
	#endregion
	
	#region BLIT
	var blit_shader_spirv := BLOOD_COMPUTE_BLIT.get_spirv()
	var blit_shader_rd := rd.shader_create_from_spirv(blit_shader_spirv,"BloodBlit")
	var blit_rid := RenderingServer.texture_get_rd_texture(blit_texture.get_rid())
	var sampler_state := RDSamplerState.new()
	sampler_state.unnormalized_uvw = true
	var sampler_rd := rd.sampler_create(sampler_state)
	var blit_texture_uniform := RDUniform.new()
	blit_texture_uniform.binding = 0
	blit_texture_uniform.add_id(sampler_rd)
	blit_texture_uniform.add_id(blit_rid)
	blit_texture_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
	blit_texture_uniform_set = rd.uniform_set_create([blit_texture_uniform],blit_shader_rd,1)
	
	#PositionBuffer
	position_buffer = rd.storage_buffer_create(4*4)
	rd.buffer_clear(position_buffer,0,4*4)
	var position_uniform := RDUniform.new()
	position_uniform.binding = 0
	position_uniform.add_id(position_buffer)
	position_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	position_buffer_set = rd.uniform_set_create([position_uniform],blit_shader_rd,2)
	blit_pipeline = rd.compute_pipeline_create(blit_shader_rd)
	#endregion
	
	var blood_map_tex_rd = Texture2DRD.new()
	blood_map_tex_rd.texture_rd_rid = map_texture
	blood_sprite.texture = blood_map_tex_rd
	decay_timer.timeout.connect(dispatch_decay)

var mouse_spawning := false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_spawning = event.pressed

var autofill_last_position:Vector2

func _process(delta: float) -> void:
	if mouse_spawning:
		blit_blood(blood_sprite.get_local_mouse_position() + Vector2(width/2,height/2))
	if autofill.button_pressed:
		blit_blood(autofill_last_position)
		autofill_last_position.x += 1
		if autofill_last_position.x >= width:
			autofill_last_position.x = 0
			autofill_last_position.y += 1
			if autofill_last_position.y >= height:
				autofill.button_pressed = false
				autofill_last_position = Vector2i.ZERO
	pass

@onready var compute_lock:Mutex = Mutex.new()

func blit_blood(dst:Vector2i) -> void:
	var data = blit_data.new()
	data.dst = dst
	var buffer_data = data.toByteArray()
	rd.buffer_update(position_buffer,0,4*4,buffer_data)
	
	compute_lock.lock()
	var list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(list,blit_pipeline)
	rd.compute_list_bind_uniform_set(list,blood_map_uniform_set,0)
	rd.compute_list_bind_uniform_set(list,blit_texture_uniform_set,1)
	rd.compute_list_bind_uniform_set(list,position_buffer_set,2)
	rd.compute_list_dispatch(list,blit_texture.get_width(),blit_texture.get_height(),1)
	rd.compute_list_end()
	compute_lock.unlock()


## 1% reduction in blood color
## textures must be divisible by 8 to fit the dispatch invocations
func dispatch_decay() -> void:
	compute_lock.lock()
	var list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(list,decay_pipeline)
	rd.compute_list_bind_uniform_set(list,blood_map_uniform_set,0)
	rd.compute_list_dispatch(list,width/8,height/8,1)
	rd.compute_list_end()
	compute_lock.unlock()
