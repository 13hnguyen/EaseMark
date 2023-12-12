extends Node


class_name SpeedMarkControl

@export var ease_mark: EaseMark:
    set(em):
        ease_mark = em
        em.ease_mark_changed.connect(bake_speed_curve)

@export var arc: Arc

var curve_len:Array[float] = []
var total_length: float = 0.0

var current_position := 0.0
var current_curve : int = 0
var animation_time :=0.0
func get_sample(delta: float) -> float:
#    if speed_curve:
#        var sample := speed_curve[floor(delta*speed_curve.size())]
#        return sample.y/100.0
    if total_length == 0:
        return 0.0
    
    var offset :float = current_position 
    current_curve = floor(current_position)
    offset -= current_curve
    
    var curve:=ease_mark.curves[current_curve]
    
    var value := curve.sample_baked(offset*curve.get_baked_length())
    
    var old_position = current_position
    current_position += func_len(value.y)*delta
    
    if current_position >= ease_mark.curves.size():
        current_position -= ease_mark.curves.size()
    
    return old_position
    
    
    
        
#    var curve:= curve_len.bsearch(adjusted)
#    if curve >= speed_curves.size():
#        return 0.0
#    var point := speed_curves[curve].bsearch(adjusted)
#    #print(curve + point * 1.0/speed_curves[curve].size())
#    return curve + point * 1.0/speed_curves[curve].size()

func func_len(x: float) -> float:
    return pow(10.,(x/100.0)) #pow(10.0, 2-2*x)

func bake_speed_curve() -> void:
    curve_len.clear()
    total_length = 0.0
    
    var idx := 0
    
    for curve in ease_mark.curves:
        var curve_length := curve.get_baked_length()
        idx += curve_length
        curve_len.append(idx)
    
    total_length = idx
    
    current_position = 0.0
    current_curve = 0
    


func _on_ease_mark_container_ease_mark_update() -> void:
    pass # Replace with function body.
