module maths.camera.camera3d;
/**
 *
 */
import maths.all;

final class Camera3D {
    enum Mode { GL, VULKAN }
    Mode mode = Mode.GL;
	Vector3 _position;
	Vector3 _forward;
	Vector3 _up;
	float _focalLength;
	Angle!float _fov = 60.degrees;
	float _near = 0.1f, _far = 100f;
	Dimension _windowSize;
	Matrix4 view	 = Matrix4.identity;
	Matrix4 proj	 = Matrix4.identity;
	Matrix4 viewProj = Matrix4.identity;
	Matrix4 invViewProj = Matrix4.identity;
	bool recalculateView = true;
	bool recalculateProj = true;
	bool recalculateViewProj = true;
	bool recalculateInvViewProj = true;
private:

public:
	Vector3 position() 		{ return _position; }
	Vector3 up() 			{ return _up; }
	Vector3 forward() 		{ return _forward; }
	Vector3 right() 		{ return _forward.right(_up); }
	Vector3 focalPoint() 	{ return _position+_forward*_focalLength; }
	Dimension windowSize() 	{ return _windowSize; }
    float aspectRatio() 	{ return _windowSize.width/_windowSize.height; }
    Angle!float fov() 		{ return _fov; }
    float near() 			{ return _near; }
    float far() 			{ return _far; }

	override string toString() {
		return "[Camera pos:%s forward:%s up:%s"
			.format(_position.toString(2), _forward.toString(2), _up.toString(2));
	}

	this(Dimension windowSize, Vector3 pos, Vector3 up, Vector3 focalPoint) {
		this._windowSize  = windowSize;
		this._position	  = pos;
		this._up		  = up.normalised();
		this._forward     = (focalPoint-pos).normalised();
		this._focalLength = (focalPoint-pos).magnitude();
	}
	/**
	 * Assumption 1:
	 *    Resize will be called to set the windowSize before use.
	 * Assumption 2:
	 *    Up vector is _forward rotated by the X-axis by
	 *    90 degrees. Use pitch to change the _up vector later.
	 */
	this(Vector3 pos, Vector3 focalPoint) {
        this._windowSize  = Dimension(0,0);
        this._position	  = pos;
        this._forward     = (focalPoint-pos).normalised();
        this._focalLength = (focalPoint-pos).magnitude();
        // Calculate up
        if(_forward.isParallelTo(vec3(0,1,0))) {
            // Up is anywhere around the y axis
            this._up = vec3(0,0,-1);
        } else {
            this._up = _forward.rotatedTo(vec3(0,1,0), 90.degrees);
        }
    }
    static Camera3D forGL(T)(Vec2!T windowSize, Vector3 pos, Vector3 focalPoint) {
        auto c = new Camera3D(pos, focalPoint);
        c.resize(windowSize);
        c.mode = Mode.GL;
        return c;
    }
    static Camera3D forVulkan(T)(Vec2!T windowSize, Vector3 pos, Vector3 focalPoint) {
        auto c = new Camera3D(pos, focalPoint);
        c.resize(windowSize);
        c.mode = Mode.VULKAN;
        return c;
    }
    auto vulkanMode() {
        mode = Mode.VULKAN;
        return this;
    }
	auto fovNearFar(Angle!float fov, float near, float far) {
		this._fov  = fov;
		this._near = near;
		this._far  = far;
		recalculateProj = true;
		return this;
	}
	auto resize(T)(Vec2!T windowSize) {
	    assert(windowSize.width>0 && windowSize.height>0);
        this._windowSize = windowSize.to!float;
	    recalculateProj  = true;
	    return this;
	}
	/// position and focal point move forward/back
	auto moveForward(float f) {
		auto dist  = _forward * f;
		_position += dist;
		recalculateView = true;
		return this;
	}
	auto movePositionRelative(vec3 newpos) {
	    _position += newpos;
	    recalculateView = true;
        return this;
	}
	auto movePositionAbsolute(vec3 newpos) {
        _position = newpos;
        recalculateView = true;
        return this;
    }
	auto strafeRight(float f) {
		auto right   = _forward.right(_up);
		auto dist    = right * f;
		_position   += dist;
		recalculateView = true;
		return true;
	}
	/// move focal point left/right (around y plane)
	auto yaw(float f) {
		auto right   = _forward.right(_up);
		auto dist    = right * f;
		_forward += dist;
		_forward.normalise();
		recalculateView = true;
		return this;
	}
	/// move focal point up/down (around x plane)
	auto pitch(float f) {
		auto right   = _forward.right(_up);
		auto dist    = _up * f;
		_forward += dist;
		_forward.normalise();
		_up = right.right(_forward);
		recalculateView = true;
		return this;
	}
	// tip (around z plane)
	auto roll(float f) {
		auto dist = right() * f;
		_up += dist;
		_up.normalise();
		recalculateView = true;
		return this;
	}
	ref Matrix4 P() {
		if(recalculateProj) {
		    if(mode==Mode.VULKAN)
				/**
				* Near and far planes reversed to allow for more accurate depth buffer
				* using near plane of 1.0 and a far plane of 0.0
				*/
		        proj = vkPerspectiveRH(
                        _fov,
                        _windowSize.width / _windowSize.height,
                        _far,
						_near);
            else
                proj = Matrix4.perspective(
                        _fov,
                        _windowSize.width / _windowSize.height,
                        _near,
                        _far);
			recalculateProj = false;
			recalculateViewProj = true;
			recalculateInvViewProj = true;
		}
		return proj;
	}
	ref Matrix4 V() {
		if(recalculateView) {
			view = Matrix4.lookAt(
				_position,		// camera _position in World Space
				focalPoint(),	// position we are looking at
				_up				// head is up
			);
			recalculateView = false;
			recalculateViewProj = true;
			recalculateInvViewProj = true;
		}
		return view;
	}
	ref Matrix4 VP() {
		if(recalculateView || recalculateProj || recalculateViewProj) {
			V();
			P();
			viewProj = proj * view;
			recalculateViewProj = false;
			recalculateInvViewProj = true;
		}
		return viewProj;
	}
	ref Matrix4 inverseVP() {
		if(recalculateInvViewProj) {
			invViewProj = VP().inversed();
			recalculateInvViewProj = false;
		}
		return invViewProj;
	}
	/// origin is top-left
    Vector3 screenToWorld(float screenX, float screenY, float depthZ) {
        float invScreenY = (_windowSize.height - screenY);
        return Vector3.unProject(
            Vector3(screenX, invScreenY, depthZ),
            inverseVP(),
            Rect(Point(0,0), _windowSize)
        );
    }
    Vector3 worldToScreen(Vector3 v, bool topLeftOrigin=true) {
        auto p = Vector3.project(v, V, P, Rect(Point(0,0), _windowSize));
        if(topLeftOrigin) {
            return Vector3(p.x, cast(float)(_windowSize.height)-p.y, p.z);
        }
        return p;
    }
}



