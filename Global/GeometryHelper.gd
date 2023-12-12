extends Node

class_name GeometryHelper

static func get_closest_rect_point(point: Vector2, rect: Rect2,on_border: bool = true) -> Vector2:
    rect = rect.abs()
    
    if not on_border and rect.has_point(point):
        return point
    
    var min_distance: float = INF
    var closest_point: Vector2 = rect.get_center()
    
    var point_a = rect.position
    var point_b = rect.position + Vector2(rect.size.x, 0.0)
    
    var point_c = Geometry2D.get_closest_point_to_segment(point, point_a, point_b)
    var new_distance = point_c.distance_squared_to(point)
    if min_distance > new_distance:
        min_distance = new_distance
        closest_point = point_c
    
    point_a = rect.position
    point_b = rect.position + Vector2(0.0, rect.size.y)
    
    point_c = Geometry2D.get_closest_point_to_segment(point, point_a, point_b)
    new_distance = point_c.distance_squared_to(point)
    if min_distance > new_distance:
        min_distance = new_distance
        closest_point = point_c

    point_a = rect.position + rect.size
    point_b = rect.position + Vector2(0.0, rect.size.y)
    
    point_c = Geometry2D.get_closest_point_to_segment(point, point_a, point_b)
    new_distance = point_c.distance_squared_to(point)
    if min_distance > new_distance:
        min_distance = new_distance
        closest_point = point_c
        
    point_a = rect.position + rect.size
    point_b = rect.position + Vector2(rect.size.x, 0.0)
    
    point_c = Geometry2D.get_closest_point_to_segment(point, point_a, point_b)
    new_distance = point_c.distance_squared_to(point)
    if min_distance > new_distance:
        min_distance = new_distance
        closest_point = point_c

    return closest_point
