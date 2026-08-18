import 'package:test/test.dart';
import 'package:thermion_dart/src/filament/src/interface/camera.dart';
import 'package:thermion_dart/src/filament/src/interface/view.dart';
import 'package:thermion_dart/src/input/src/implementations/fixed_orbit_camera_delegate_v2.dart';
import 'package:thermion_dart/thermion_dart.dart';

class _FakeCamera extends Camera<Object?> {
  Matrix4 modelMatrix;

  _FakeCamera(this.modelMatrix);

  @override
  Object? getNativeHandle() => null;

  @override
  Future<Matrix4> getModelMatrix() async => modelMatrix.clone();

  @override
  Future<void> setModelMatrix(Matrix4 matrix) async {
    modelMatrix = matrix.clone();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeView extends View<Object?> {
  final _FakeCamera camera;

  _FakeView(this.camera);

  @override
  Object? getNativeHandle() => null;

  @override
  Future<Camera> getCamera() async => camera;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<double> _handleScroll({required double delta}) async {
  final camera = _FakeCamera(Matrix4.translation(Vector3(0, 0, 10)));
  final delegate = OrbitInputHandlerDelegate(
    _FakeView(camera),
    minZoomDistance: 2,
    maxZoomDistance: 20,
    sensitivity: const InputSensitivityOptions(scrollWheelSensitivity: 0.1),
  );

  await delegate.handle([
    ScrollEvent(localPosition: Vector2.zero(), delta: delta),
  ]);
  return (await camera.getModelMatrix()).getTranslation().length;
}

void main() {
  test('scroll changes orbit radius with the expected sign', () async {
    expect(await _handleScroll(delta: -20), closeTo(8, 0.001));
    expect(await _handleScroll(delta: 20), closeTo(12, 0.001));
  });

  test('scroll clamps orbit radius to both zoom limits', () async {
    expect(await _handleScroll(delta: -1000), closeTo(2, 0.001));
    expect(await _handleScroll(delta: 1000), closeTo(20, 0.001));
  });

  test('vertical orbit inversion is opt-in', () {
    expect(const InputSensitivityOptions().invertVerticalOrbit, isFalse);
    expect(
      const InputSensitivityOptions(invertVerticalOrbit: true)
          .invertVerticalOrbit,
      isTrue,
    );
  });
}
