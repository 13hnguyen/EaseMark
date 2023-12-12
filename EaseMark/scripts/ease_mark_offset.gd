extends EaseMarkControl


func behave(idx: int, sample: Vector2, object: Node2D) -> void:
    var arc_segment := arc.segments[idx]
    var offset = arc_segment.x
    
    
    var segment_range = arc_segment.y - arc_segment.x
    offset += int(sample.y*segment_range/100.0)
    
    var val = arc.trajectory[offset]
    object.transform = object.transform.translated(val) 
