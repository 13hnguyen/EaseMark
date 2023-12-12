extends Pen

signal v_mirror(idx: int)
signal h_mirror(idx: int)
signal hover(idx: int)

@export var magnet_dist: int = 10

var coordinates: PackedVector2Array = []
var curve: PackedByteArray = []

var rects : Array[Rect2] = [] 
var zero_position: int = 0

var last_curve = -1

func on_right_click() -> void:
    if not get_rect().has_point(get_local_mouse_position()): 
        return
    right_click.emit(last_point["curve"])
    
func on_key_pressed(event: InputEventKey) -> void:
    if not get_rect().has_point(get_local_mouse_position()): 
        return
    if not last_point.has("curve"):
        return
    if last_point["curve"] == -1:
        return
    if event.keycode == KEY_H and event.pressed == false and event.echo == false:
        h_mirror.emit(last_point["curve"])
    elif event.is_action_released("vertical_mirror"):
        v_mirror.emit(last_point["curve"])

func on_pressed() -> void:
    coordinates = []
    curve = []
    super()

func add_new_point() -> void:
    super()
    if not last_point.has("curve"):
        return
        
    var this_curve := -1
    
    if curve.size() > 0:
        this_curve = curve[-1]
    
    if last_point["curve"] != this_curve and this_curve != -1:
        curve.append(this_curve)
        coordinates.append(GeometryHelper.get_closest_rect_point(last_point["position"], rects[this_curve]))
        if last_point["curve"] != -1:
            curve.append(last_point["curve"])
            coordinates.append(GeometryHelper.get_closest_rect_point(last_point["position"], rects[last_point["curve"]]))
        
    if last_point["curve"] == -1:
        return
        
    curve.append(last_point["curve"])
    coordinates.append(last_point["position"])
        

func _read_point(point_position: Vector2) -> void:
    last_point["curve"] = -1
    for idx in rects.size():
        if rects[idx].has_point(point_position):
            last_point["curve"] = idx
            break
    if last_point["curve"] != last_curve:
        hover.emit(last_point["curve"])
    last_curve = last_point["curve"]
    super(point_position)

func _draw() -> void:
    if last_point.has("curve") and  last_point["curve"] != -1:
        var p := Vector2(
            last_point["position"].x,
            zero_position
        )
        draw_dashed_line(last_point["position"],p, Color.AQUAMARINE, 4.0, 4.0)
    
    if coordinates.size() > 2:
        draw_polyline(coordinates, Color.AQUAMARINE, 4.0)
