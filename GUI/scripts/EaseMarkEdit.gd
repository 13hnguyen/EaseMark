extends ColorRect

class_name EaseMarkEdit

@export var default_curves: DefaultCurve = preload("res://EaseMark/defaults/mirror/mirror_default.tres")

var ease_mark: EaseMark:
    set(e):
        ease_mark = e
        if ease_mark:
            ease_mark.ease_mark_changed.connect(_on_resized)
        _on_resized()

@export_range(0, 100) var px_dist: int = 10:
    set(p):
        px_dist = p
        queue_redraw()

@export var curve_min: float = -100:
    set(c):
        curve_min = c
        _on_resized()
        
@export var curve_max: float = 100:
    set(c):
        curve_max = c
        _on_resized()
        
var zero_position : int = 0

@onready var frame: Control = $Frame
@onready var pen: Control = $Pen

var rects: Array[Rect2] = []
var baked_points: Array[PackedVector2Array] = []
var fitted_curves: Array[PackedVector2Array] = []

var curve_default_index :Array[int]= []

func bake_points()->void:
    baked_points = []
    var curve_range := curve_max-curve_min
    
    for i in rects.size():
        var rec := rects[i]
        var arr := ease_mark.curves[i].get_baked_points()
        var translate_tform:=Transform2D().translated(Vector2(rec.position.x, zero_position))
        var scale_tform:=Transform2D().scaled(Vector2(rec.size.x/100.0, -rec.size.y/curve_range))
        arr = translate_tform * scale_tform * arr
        
        baked_points.append(arr.duplicate())
      

func _ready() -> void:
    pass

func refit_curve(idx: int, new_points: PackedVector2Array) -> void:
    var points = baked_points[idx]
    var rec := rects[idx]
    
    var curve_range := curve_max-curve_min
    
    new_points.sort()
    points.sort()
    
    var before : int = 0
    var after : int = points.size()-1
    
    var min_x : float = new_points[0].x
    var max_x : float = new_points[-1].x
    
    for i in points.size():
        if points[i].x <= min_x:
            before = i
        if points[i].x < max_x:
            after = i
    var final : PackedVector2Array = []
    
    if min_x > rec.position.x + 2.0:
        final = points.slice(0, before)
        
    final.append_array(new_points)
    
    if max_x < rec.position.x + rec.size.x - 2.0:
        final.append_array(points.slice(after, points.size()))
    
    var final_final : PackedVector2Array = [final[0]]
    
    for p in final:
        if p.x - final_final[-1].x <= 2.0:
            continue
        final_final.append(p)
    
    fitted_curves.append(final_final.duplicate())
    baked_points[idx] = final_final.duplicate()
    
    var translate_tform:=Transform2D().translated(Vector2(-rec.position.x, -zero_position))
    var scale_tform:=Transform2D().scaled(Vector2(100.0/rec.size.x, -curve_range/rec.size.y))
    
    final_final = scale_tform * translate_tform * final_final
    
    var fit := FitCurve.new(final_final.duplicate(), 100.)
    
    ease_mark.set_curve(fit.fitted_curve,idx)
    
    curve_default_index[idx] = -1

func _on_pen_pen_lifted() -> void:
    
#    for idx in pen.coordinates.size():
#        var coord := pen.coordinates[idx] as Vector2
#        var curve := pen.curve[idx] as int
#
#        var rect := rects[curve]
#
#        coord -= Vector2(rect.position.x, zero_position)
#        coord *= Vector2(1.0/rect.size.x, (curve_min-curve_max)/rect.size.y)
#
#
#        ease_mark.curves[curve].add_point(coord)
        #ease_mark.curves[curve].clean_dupes()
    
    if pen.coordinates.size() < 2:
        return
    
    var strokes : Array[PackedVector2Array] = []
    
    
    var current_index :int= pen.curve[0]
    var curve_index: Array[int] = [current_index]
    
    var current_point :Vector2= pen.coordinates[0]
    var current_stroke: PackedVector2Array = [current_point]
    var current_direction: bool = (pen.coordinates[1].x>current_point.x)
    
    for i in range(1,pen.coordinates.size()):
        var point :Vector2= pen.coordinates[i]
        if point.x <= current_point.x:
            continue
        var direction :bool= bool(point.x > pen.coordinates[i-1].x)
        if pen.curve[i] != current_index:
            current_index = pen.curve[i]
            current_point = point
            strokes.append(current_stroke)
            curve_index.append(current_index)
            current_stroke = []
            current_direction = direction
        current_stroke.append(point)
        current_point = point
        
    strokes.append(current_stroke)
    curve_index.append(current_index)
    fitted_curves = []
    for i in strokes.size():
        refit_curve(curve_index[i], strokes[i])
    
    
    pen.coordinates = []
    pen.curve = []
    

func _on_pen_pen_reset() -> void:
    pass # Replace with function body.

    
func _on_pen_stroke_changed() -> void:
    pass # Replace with function body.

func _draw() -> void:
#    var num_arcs:= baked_points.size()
#
#    var frame_rect := frame.get_rect()
#
#    var pos_mid := (frame_rect.size.y/2) + frame_rect.position.y
#    var x_range = (frame_rect.size.x - (num_arcs-1)*px_dist)/num_arcs
#
#    var x_start = frame_rect.position.x
    
    seed(0)
    
    var curve_range := curve_max-curve_min
    
    
    for idx in rects.size():
        var rand_color = Color(randf(), randf(), randf())
        var rec := rects[idx] as Rect2
        draw_line(Vector2(rec.position.x, zero_position), Vector2(rec.position.x + rec.size.x, zero_position), rand_color, 3.0)
        draw_rect(rec, rand_color, false, 1.0)
        
        draw_polyline(baked_points[idx], Color.WHITE, 1.0)
    
    for fit in fitted_curves:
        var rand_color = Color(randf(), randf(), randf())
        #draw_polyline(fit, rand_color, 5.0)
        
#    var tform := Transform2D()
#    tform = tform.scaled(Vector2(x_range,-0.5*frame_rect.size.y))
#
#
#    for idx in num_arcs:
#        var rand_color = Color(randf(), randf(), randf())
#        var temp_tform = tform.translated(Vector2(x_start, pos_mid))
#
#        draw_line(Vector2(x_start, pos_mid), Vector2(x_start+x_range, pos_mid), rand_color, 3.0)
#        var dashed_line :PackedVector2Array= temp_tform * baked_points[idx]
#        draw_polyline(dashed_line, Color.WHITE, 5.0)
#        x_start += x_range + px_dist


func _on_resized() -> void:
    if not pen:
        return
    rects = []
    var num_arcs:= ease_mark.curves.size()
    var frame_rect := frame.get_rect()
    
    var curve_range := curve_max-curve_min
    
    zero_position =  int(frame_rect.position.y + frame_rect.size.y + curve_min * float(frame_rect.size.y)/curve_range)
    
    var x_range = (frame_rect.size.x - (num_arcs-1)*px_dist)/num_arcs
    var x_start = frame_rect.position.x
    
    
    
    var rect_size := Vector2(x_range, frame_rect.size.y)
    
    for idx in num_arcs:
        var pos: Vector2 = Vector2(x_start, frame_rect.position.y)
        var rec2: Rect2 = Rect2(pos, rect_size)
        rects.append(rec2)
        x_start += x_range + px_dist
    
    for i in range(curve_default_index.size(), num_arcs):
        curve_default_index.append(0)
    
    pen.rects = rects
    pen.zero_position = zero_position

    bake_points()
    queue_redraw()


func _on_pen_right_click(idx) -> void:
    if idx != -1:
        curve_default_index[idx] = curve_default_index[idx] + 1
        
        if curve_default_index[idx] >= default_curves.array_curve.size():
            curve_default_index[idx] = 0
            
        
        var curve := default_curves.get_curve(curve_default_index[idx])
        ease_mark.set_curve(curve, idx)
        
    bake_points()
    queue_redraw()



func _on_pen_h_mirror(idx) -> void:
    if idx == -1:
        return
        
    var current_rect :Rect2= rects[idx]
    var current_curve :Curve2D= ease_mark.curves[idx]
    
    var scale_tform:=Transform2D().scaled(Vector2(-1.0, 1.0))
    var translate_tform :=Transform2D().translated(Vector2(100.0, 0.0))
    var in_scale_tform:=Transform2D().scaled(Vector2(1.0, -1.0))
    var tform = translate_tform * scale_tform
    
    var new_curve: Curve2D = Curve2D.new()
    
    for _i in current_curve.point_count:
        var i = current_curve.point_count-_i-1
        print(i)
        var point_in :Vector2= scale_tform*current_curve.get_point_in(i)
        var point_position :Vector2= tform*current_curve.get_point_position(i)
        var point_out :Vector2= scale_tform*current_curve.get_point_out(i)
        
        new_curve.add_point(point_position, point_out, point_in)
    ease_mark.set_curve(new_curve, idx)
    bake_points()
    queue_redraw()


func _on_pen_v_mirror(idx) -> void:
    if idx == -1:
        return
        
    var current_rect :Rect2= rects[idx]
    var current_curve :Curve2D= ease_mark.curves[idx]
    
    var curve_middle := (curve_max+curve_min)/2.0
    var scale_tform:=Transform2D().scaled(Vector2(1.0, -1.0))
    var translate_tform :=Transform2D().translated(Vector2(0.0, -curve_middle))
    var translate_tform_2 :=Transform2D().translated(Vector2(0.0, curve_middle))
    
    var tform = translate_tform_2 * scale_tform * translate_tform
    
    var new_curve: Curve2D = Curve2D.new()
    
    for _i in current_curve.point_count:
        var i = _i
        print(i)
        var point_in :Vector2= scale_tform*current_curve.get_point_in(i)
        var point_position :Vector2= tform*current_curve.get_point_position(i)
        var point_out :Vector2= scale_tform*current_curve.get_point_out(i)
        
        new_curve.add_point(point_position, point_in, point_out)
    ease_mark.set_curve(new_curve, idx)
    bake_points()
    queue_redraw()


func _on_pen_hover(idx: int) -> void:
    ease_mark.is_user_hovering = idx
