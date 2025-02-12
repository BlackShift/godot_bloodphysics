extends CanvasLayer

@onready var fps: Label = %FPS
@onready var back_button: Button = %back_button
@onready var vsync: CheckButton = $PanelContainer/MarginContainer/VBoxContainer/vsync
@onready var panel_container: PanelContainer = $PanelContainer
@onready var draw_calls: Label = %DrawCalls

const MENU = "res://menu.tscn"

func _ready() -> void:
	back_button.pressed.connect(on_back)
	vsync.button_pressed = true if DisplayServer.window_get_vsync_mode(get_window().get_window_id()) else false
	vsync.toggled.connect(vsync_toggle)
	panel_container.grab_focus()

func _process(delta: float) -> void:
	fps.text = String.num(Performance.get_monitor(Performance.TIME_FPS),2)
	draw_calls.text = String.num(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),0)

func on_back() -> void:
	get_tree().change_scene_to_file(MENU)

func vsync_toggle(toggled_on:bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED,get_window().get_window_id())
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED,get_window().get_window_id())
	pass
