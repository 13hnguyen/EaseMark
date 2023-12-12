extends Node

## GDScript implementation of Philip J. Schneider's 
## "Algorithm for Automatically Fitting Digitized Curves" from the book "Graphics Gems" 
## Python Implementation: https://github.com/volkerp/fitCurves/
## Original C Implementation: http://graphicsgems.org/ 
class_name FitCurve

signal fitting_done

const MAX_ITERATIONS = 4

var fitted_curve: Curve2D = Curve2D.new()
var fitted_beziers: Array[Bezier] = []

class Bezier:
    var p0: Vector2
    var p1: Vector2
    var p2: Vector2
    var p3: Vector2
    
    func _init(p0_, p1_, p2_, p3_) -> void:
        p0 = p0_
        p1 = p1_
        p2 = p2_
        p3 = p3_
    
    # evaluates cubic beszier at t, return point
    func q(t: float) -> Vector2:
        var m_t := 1.0 - t
        return (
                  pow(m_t, 3)            * p0 
            + 3 * pow(m_t, 2) * t        * p1
            + 3 * m_t         * pow(t,2) * p2
            +                   pow(t,3) * p3
            )
    
    # evaluates cubic beszier first derivative at t, return point
    func qprime(t: float) -> Vector2:
        var m_t := 1.0 - t
        return (
              3 * pow(m_t, 2)            * (p1-p0) 
            + 6 * m_t         * t        * (p2-p1)
            + 3               * pow(t,2) * (p3-p2)
            )
    
    # evaluates cubic beszier second derivative at t, return point
    func qprimeprime(t: float) -> Vector2:
        var m_t := 1.0 - t
        return (
              6 * m_t * (p2 - 2*p1 + p0) 
            + 6 * t   * (p3 - 2*p2 + p1)
            )
    
    
func _init(polyline: PackedVector2Array, error: float = 4.0) -> void:
    if polyline.size() < 2:
        fitting_done.emit()
        return
    fitted_curve.bake_interval = 1
    
    var next_point: Vector2 = polyline[0]
    for point in polyline:
        if point != polyline[0]:
            next_point = point
            break
    var left_tangent: Vector2 = (next_point - polyline[0]).normalized()
    var right_tangent: Vector2 = (polyline[-2] - polyline[-1]).normalized()
    fitted_beziers = fit_cubic(polyline, left_tangent, right_tangent, error)
    beziers_to_curve_2d(fitted_beziers)
    fitting_done.emit()
    
# Converting Bezier curves to Curve2D
func beziers_to_curve_2d(beziers: Array[Bezier]) -> void:
    fitted_curve.clear_points()
    
    var first_bez := beziers[0]
    var first_tan : Vector2 = first_bez.p0-first_bez.p1
    fitted_curve.add_point(first_bez.p0, first_tan, -first_tan)
    
    for i in range(1,beziers.size()):
        var bez := beziers[i]
        var prev_bez := beziers[i-1]
        fitted_curve.add_point(bez.p0, prev_bez.p2- bez.p0, bez.p1-bez.p0)
    
    var last_bez := beziers[-1]
    fitted_curve.add_point(last_bez.p3, last_bez.p2-last_bez.p3, last_bez.p3-last_bez.p2)
    
func fit_cubic(polyline: PackedVector2Array, left_tangent: Vector2, right_tangent: Vector2, error: float) -> Array[Bezier]:
    # Use heuristic if region only has two points in it
    if polyline.size() == 2:
        var dist: float = polyline[0].distance_to(polyline[1]) / 3.0
        var bez := Bezier.new(polyline[0], polyline[0] + left_tangent*dist, polyline[1] + right_tangent * dist, polyline[1])
        return [bez]
    
    # Parametrize points, and attempt to fit curve
    var u = chord_length_parametrize(polyline)
    var bez_curve: Bezier = generate_bezier(polyline, u, left_tangent, right_tangent)
    
    # Find max deviation of points to fitted curve
    var _max_error_split_point = compute_max_error(polyline, bez_curve, u)
    var max_error: float = _max_error_split_point[0]
    if max_error < error:
        return [bez_curve]
    var split_point: int = _max_error_split_point[1]
    
    # If error not too large, try some reparametrization and iteration
    if max_error < error*error:
        for i in MAX_ITERATIONS:
            var u_prime = reparametrize(bez_curve, polyline, u)
            bez_curve = generate_bezier(polyline, u_prime, left_tangent, right_tangent)
            _max_error_split_point = compute_max_error(polyline, bez_curve, u)
            max_error = _max_error_split_point[0]
            if max_error < error:
                return [bez_curve]
            split_point = _max_error_split_point[1]
            u = u_prime
    
    # Fitting failed -- split at max error point and fit recursively
    var beziers: Array[Bezier] = []
    var center_tangent: Vector2 = (polyline[split_point-1]-polyline[split_point+1]).normalized()
    beziers += fit_cubic(polyline.slice(0, split_point+1), left_tangent, center_tangent, error)
    beziers += fit_cubic(polyline.slice(split_point), -center_tangent, right_tangent, error)
    
    return beziers
    
func generate_bezier(polyline: PackedVector2Array, parameters: Array[float], left_tangent: Vector2, right_tangent: Vector2) -> Bezier: 
    var bez_curve:= Bezier.new(polyline[0], Vector2.ZERO, Vector2.ZERO, polyline[-1])
    
    # compute the A's
    var A: Array[Transform2D] = []
    for u in parameters:
        var A_transform := Transform2D.IDENTITY
        A_transform.x = left_tangent  * 3 * (1-u) * (1-u) * u
        A_transform.y = right_tangent * 3 * (1-u)         * u * u
        A.append(A_transform)
    
    # Create the C and X matrices
    var C := Transform2D(Vector2.ZERO, Vector2.ZERO, Vector2.ZERO)
    var X := Vector2.ZERO
    
    var tmp_bezier:= Bezier.new(polyline[0], polyline[0], polyline[-1], polyline[-1])
    
    for i in range(polyline.size()):
        C.x.x += A[i].x.dot(A[i].x)
        C.x.y += A[i].x.dot(A[i].y)
        C.y.x += A[i].y.dot(A[i].x)
        C.y.y += A[i].y.dot(A[i].y)
        
        var tmp: Vector2 = polyline[i] - tmp_bezier.q(parameters[i])
        
        X.x += A[i].x.dot(tmp)
        X.y += A[i].y.dot(tmp)
    
    # Compute the determinants of C and X
    var det_C0_C1: float = C.x.x * C.y.y - C.y.x * C.x.y
    var det_C0_X: float = C.x.x * X.y - C.y.y * X.x
    var det_X_C1: float = X.x * C.y.y - X.y * C.x.y
    
    # Finally, derive alpha values
    var alpha_l: float = 0.0 if det_C0_C1 == 0 else det_X_C1 / det_C0_C1
    var alpha_r: float = 0.0 if det_C0_X == 0 else det_X_C1 / det_C0_C1
    
    # If alpha negative, use the Wu/Barsky heuristic (see text)
    # (if alpha is 0, you get coincident control points that lead to
    # divide by zero in any subsequent NewtonRaphsonRootFind() call.
    var seg_length: float = polyline[0].distance_to(polyline[1])
    var epsilon: float = exp(-6) * seg_length
    if alpha_l < epsilon or alpha_r < epsilon:
        # fall back on standard (probably inaccurate) formula, and subdivide further if needed.
        bez_curve.p1 = bez_curve.p0 + left_tangent * (seg_length/3.0)
        bez_curve.p2 = bez_curve.p3 + right_tangent * (seg_length/3.0)
    
    else:
        # First and last control points of the Bezier curve are
        # positioned exactly at the first and last data points
        # Control points 1 and 2 are positioned an alpha distance out
        # on the tangent vectors. left and right, respectively
        bez_curve.p1 = bez_curve.p0 + left_tangent * alpha_l
        bez_curve.p2 = bez_curve.p3 + right_tangent * alpha_r
        
    return bez_curve
    
func reparametrize(bezier: Bezier, polyline: PackedVector2Array, parameters: Array[float]) -> Array[float]:
    var u_prime: Array[float] = []
    for i in polyline.size():
        u_prime.append(newton_raphson_root_find(bezier, polyline[i], parameters[i]))
    return u_prime


#       Newton's root finding algorithm calculates f(x)=0 by reiterating
#       x_n+1 = x_n - f(x_n)/f'(x_n)
#
#       We are trying to find curve parameter u for some point p that minimizes
#       the distance from that point to the curve. Distance point to curve is d=q(u)-p.
#       At minimum distance the point is perpendicular to the curve.
#       We are solving
#       f = q(u)-p * q'(u) = 0
#       with
#       f' = q'(u) * q'(u) + q(u)-p * q''(u)
#
#       gives
#       u_n+1 = u_n - |q(u_n)-p * q'(u_n)| / |q'(u_n)**2 + q(u_n)-p * q''(u_n)|
func newton_raphson_root_find(bez: Bezier, point: Vector2, u: float) -> float:
    var delta: Vector2 = bez.q(u) - point
    var numerator_vec: Vector2 = delta * bez.qprime(u)
    var denominator_vec: Vector2 = delta * bez.qprimeprime(u) + Vector2(pow(numerator_vec.x,2), pow(numerator_vec.y,2))
    
    var numerator: float = numerator_vec.x + numerator_vec.y
    var denominator: float = denominator_vec.x + denominator_vec.y
    
    if denominator == 0.0:
        return u
    
    return u - numerator/denominator

func chord_length_parametrize(polyline: PackedVector2Array) -> Array[float]:
    var u: Array[float] = [0.0]
    for i in range(1, polyline.size()):
        u.append(u[i-1] + polyline[i-1].distance_to(polyline[i]))
    
    var u_normalized: Array[float] = []
    for _u in u:
        u_normalized.append(_u/u[-1])
    return u_normalized

func compute_max_error(polyline: PackedVector2Array, bez: Bezier, parameters: Array[float]) -> Array:
    var max_dist := 0.0
    var split_point :int = polyline.size()/2
    
    for i in polyline.size():
        var dist = bez.q(parameters[i]).distance_squared_to(polyline[i])
        if dist > max_dist:
            max_dist = dist
            split_point = i
    return [max_dist, split_point]
