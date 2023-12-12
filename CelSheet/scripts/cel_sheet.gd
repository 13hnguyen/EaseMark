extends Control

class_name CelSheet

signal keys_changed

@export var arc: Arc
@export var timeline: Timeline

var arcs: PackedVector2Array = []
var fitted_arcs: Array[FitCurve] = []

var keys: Array[int] = []
var segments: Array[Vector2i] = []

@export var arc_pen: Pen

@export var show_arc: bool = true:
    set(d):
        show_arc = d
        queue_redraw()

var ease_marks: Array[EaseMark] = []
var selected: Vector2i = Vector2i(-1, -1) #x = easemark index, 
var selected_ease_mark: PackedVector2Array = []

func add_ease_mark(ease_mark: EaseMark) -> void:
    ease_marks.append(ease_mark)

func _process(_delta: float) -> void:
    var new_selected := Vector2i(-1, -1)
    
    for i in ease_marks.size():
        if ease_marks[i].is_user_hovering != -1:
            new_selected.x = i
            new_selected.y = ease_marks[i].is_user_hovering
            break
    
    if new_selected != selected:
        selected = new_selected
        bake_ease_mark.call_deferred()

func bake_ease_mark() -> void:
    selected_ease_mark = []
    if selected.x == -1:
        
        queue_redraw()
        return
    if selected.y == -1:
        queue_redraw()
        return
    
    
    var segment = segments[selected.y]
    var curve : Curve2D= ease_marks[selected.x].curves[selected.y]
    
    var slice := arcs.slice(keys[segment.x], keys[segment.y])
    
    var range :float= keys[segment.y] - keys[segment.x]    
    if range == 0.0:
        queue_redraw()
        return
    
    var dir := slice[0].direction_to(slice[-1]).normalized().rotated(-90)
    
    var length := curve.get_baked_length()
    
    var delta := 1.0 / 50.0
    
    for i in 50:
        print(i *  delta * length)
        var offset :float= (i *  delta * length)
        var point : Vector2= curve.sample_baked(offset)
        print(offset, point)
        var idx := point.x
        
        var int_idx : int = floor(idx*range/100)
        
        var val := dir * point.y
        
        
        selected_ease_mark.append(slice[int_idx] + val)
        
    
#    var delta :float= 1.0 / range    
#
#    for j in slice.size()-1:
#        var i = j
#        var i2 = (j+1)
#        var dir = slice[i].direction_to(slice[i2]).normalized()
#        var val = curve.sample_baked(i*delta * length).y
#        selected_ease_mark.append(dir.rotated(-90) * val + slice[i])
#
#
    queue_redraw()

func _ready() -> void:
    arc_pen.on_reset()


func _draw() -> void:
    if not show_arc:
        return
    if selected_ease_mark.size() > 2:
        draw_polyline(selected_ease_mark, Color.RED, 5.0, true)
        
    if arc_pen.current_stroke.size() > 2:
        draw_polyline(arc_pen.current_stroke, Color.REBECCA_PURPLE, 3.0, true)
    
    for i in keys.size()-1:
        if keys[i+1]-keys[i] < 2:
            continue
        draw_polyline(arcs.slice(keys[i], keys[i+1]), Color.BLACK, 3.0, true)
        
    for key in keys:
        draw_circle(arcs[key], 8.0, Color.MEDIUM_PURPLE)
    
    
    
#    for seg in segments:
#        if seg.y - seg.x > 2:
#            draw_polyline(arcs.slice(seg.x, seg.y), Color.BLACK, 3.0, true)
#
#    for seg in segments:
#        draw_circle(arcs[seg.x], 8.0, Color.BLACK)
#        draw_circle(arcs[seg.y], 8.0, Color.BLACK)
#    for seg in segments:
#        if seg.x == seg.y:
#            draw_circle(arcs[seg.x], 8.0, Color.MEDIUM_PURPLE)
        
func _on_arc_pen_pen_lifted() -> void:
    if arc_pen.strokes.size() == 0:
        return
    var new_curve := FitCurve.new(arc_pen.strokes[-1], 100.0)
    fitted_arcs.append(new_curve)
    
    
    var baked_points := new_curve.fitted_curve.get_baked_points()
    
    if baked_points.size() < 2:
        return
    
    keys.append(arcs.size())
    arcs.append_array(baked_points)
    keys.append(arcs.size()-1)
    keys_changed.emit()
    arc_pen.arcs.append_array(baked_points)
    arc_pen.keys.append(keys[-2])
    arc_pen.keys.append(keys[-1])
#
#    var seg : Vector2i = Vector2i(arcs.size(), arcs.size()+baked_points.size()-1)
#    arcs.append_array(baked_points)
#    arc_pen.arcs.append_array(baked_points)
#    segments.append(seg)
#    arc_pen.segments.append(seg.x)
#    arc_pen.segments.append(seg.y)
#    segments_changed.emit()
    
    
    queue_redraw()


func _on_arc_pen_right_click(idx) -> void:
    if idx == -1:
        return
    for key in keys:
        if key == idx:
            return
    keys.append(idx)
    arc_pen.keys.append(idx)
    keys.sort()
    
    keys_changed.emit()
    queue_redraw()
    
func _on_arc_pen_pen_reset() -> void:
    arcs = []
    fitted_arcs = []
    keys = []
    keys_changed.emit()
    queue_redraw()
#    segments = []
#    segments_changed.emit()

func _on_arc_pen_stroke_changed() -> void:
    queue_redraw()
