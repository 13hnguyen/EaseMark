extends Node2D

@export var object: Node2D
@export var arc: Arc
@export var timeline: Timeline

@export var num_sheets: int = 10:
    set(n):
        num_sheets = n
        update_number()

func _ready() -> void:
    update_number()

func update_number() -> void:
    if not object:
        return
        
    var num_child = get_child_count()
    
    if num_child > num_sheets:
        for i in range(num_sheets, num_child):
            get_child(i).queue_free()
    elif num_child < num_sheets:
        for i in range(num_child, num_sheets):
            var instance := object.duplicate()
            add_child(instance)
    
    

func update_onion_skin() -> void:
    var num_segments:float= timeline.segments.size()
    if num_segments == 0:
        hide()
        return
    show()
    
    var alpha = 1.0/num_sheets
    var i = 0
    var t := num_segments/float(num_sheets)
    
    var progress := 0.0
    
    for child in get_children():
        
        var idx = floor(progress)
        var sample = progress - idx
        
        child.transform = Transform2D()
        
        for control in arc.get_children():
            if not control is EaseMarkControl:
                continue
            
            control.move(idx, sample, child)
        
        
        var seg := timeline.segments[idx]
        var range := arc.keys[seg.y] - arc.keys[seg.x]
        var mid_idx : int = floor(range * sample) + arc.keys[seg.x]
    
        child.translate(arc.arcs[mid_idx])
        child.modulate = Color(1.0-(alpha*i), 0.0, alpha*i, alpha*i/2.0)
        
        progress += t
        i+= 1



func _on_arc_child_entered_tree(node: Node) -> void:
    var ease_mark : EaseMark = node.ease_mark
    ease_mark.ease_mark_changed.connect(update_onion_skin)
