module maths.camera.camera2d;
/**
 *  Assumes you are using OpenGL.
 *  Call vulkanMode() if you want to use Vulkan.
 *  It has inverted Y axis and the clip space is 1/2*Z.
 *
 *  https://matthewwellings.com/blog/the-new-vulkan-coordinate-system/
 */
import maths.all;

final class Camera2D {
private:
    enum Mode { GL, VULKAN }
    Mode mode = Mode.GL;
	Vector2 _position;
	Vector2 up = Vector2(0,1);
	float rotationDegrees = 0;
	float _zoomFactor = 1;
	Dimension _windowSize;
	Matrix4 view	 = Matrix4.identity;
	Matrix4 proj	 = Matrix4.identity;
	Matrix4 viewProj = Matrix4.identity;
	bool recalculateView = true;
	bool recalculateProj = true;
	bool recalculateViewProj = true;
public:
	float zoomFactor() { return 1/_zoomFactor; }
	Vector2 position() { return _position; }
	Dimension windowSize() { return _windowSize; }

    override string toString() {
		return "[Camera pos:%s up:%s"
			.format(_position.toString(2), up.toString(2));
	}

	this(Dimension windowSize) {
		this._windowSize = windowSize;
		this._position   = Vector2(_windowSize.width/2, _windowSize.height/2);
	}
	static Camera2D forGL(T)(Vec2!T windowSize) {
        auto c = new Camera2D(windowSize.to!float);
        c.mode = Mode.GL;
        return c;
    }
	static Camera2D forVulkan(T)(Vec2!T windowSize) {
	    auto c = new Camera2D(windowSize.to!float);
	    c.mode = Mode.VULKAN;
	    return c;
	}
	auto moveTo(float x, float y) {
	    return moveTo(vec2(x,y));
	}
	auto moveTo(vec2 pos) {
        _position = pos;
        recalculateView = true;
        return this;
    }
	auto moveBy(float x, float y) {
		return moveTo(_position.x+x, _position.y+y);
	}
	auto moveBy(vec2 pos) {
        return moveTo(_position+pos);
    }
	auto zoomOut(float z) {
		this._zoomFactor += z;
		recalculateProj = true;
		return this;
	}
	auto zoomIn(float z) {
		if(_zoomFactor==0.01) return this;
		_zoomFactor -= z;
		if(_zoomFactor < 0.01) {
			_zoomFactor = 0.01;
		}
		recalculateProj = true;
		return this;
	}
	/// 0.5 = zoomed out (50%), 1 = (100%) no zoom, 2 = (200%) zoomed in
	auto setZoom(float z) {
		this._zoomFactor = 1/z;
		recalculateProj = true;
		return this;
	}
	auto rotateTo(float degrees) {
		this.rotationDegrees = degrees;
		Vector4 tempUp = Vector4(0, 1, 0, 0);
		auto rotateZ   = Matrix4.rotateZ(rotationDegrees.radians);
		auto rotatedUp = rotateZ * tempUp;
		this.up = rotatedUp.xy;
		recalculateView = true;
		return this;
	}
	auto rotateBy(float degrees) {
		return rotateTo(rotationDegrees + degrees);
	}
	void screenResized(Dimension dim) {
		// todo - _position needs to be adjusted
		recalculateProj  = true;
		this._windowSize = dim;
	}
	ref Matrix4 P() {
		if(recalculateProj) {
			float width  = _windowSize.width*_zoomFactor;
			float height = _windowSize.height*_zoomFactor;
			if(mode == Mode.VULKAN)
                proj = vkOrtho(
                    -width/2,   width/2,
                    -height/2,  height/2,
                    0f,        100f
                );
			else
			    proj = Matrix4.ortho(
                    -width/2,   width/2,
                    height/2,  -height/2,
                    0f,        100f
                );

			recalculateProj = false;
			recalculateViewProj = true;
		}
		return proj;
	}
	ref Matrix4 V() {
		if(recalculateView) {
			view = Matrix4.lookAt(
				Vector3(_position,1), // camera _position in World Space
				Vector3(_position,0), // look at the _position
				Vector3(up,0)	   // head is up
			);
			recalculateView = false;
			recalculateViewProj = true;
		}
		return view;
	}
	ref Matrix4 VP() {
		if(recalculateView || recalculateProj || recalculateViewProj) {
			V();
			P();
			viewProj = proj * view;
			recalculateViewProj = false;
		}
		return viewProj;
	}
}

