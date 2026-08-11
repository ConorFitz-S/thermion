import 'package:test/test.dart';
import 'package:thermion_dart/thermion_dart.dart';

void main() {
  test('bind rotations use parent world * local multiplication order', () {
    final parentWorld = Quaternion.axisAngle(Vector3(0, 1, 0), 0.4);
    final childLocal = Quaternion.axisAngle(Vector3(1, 0, 0), -0.2);
    final childWorld = parentWorld * childLocal;

    final transforms = [
      BoneBindTransform(
        boneIndex: 0,
        parentBoneIndex: null,
        localRotation: parentWorld,
        worldRotation: parentWorld,
      ),
      BoneBindTransform(
        boneIndex: 1,
        parentBoneIndex: 0,
        localRotation: childLocal,
        worldRotation: childWorld,
      ),
    ];

    final reconstructed =
        transforms[0].worldRotation * transforms[1].localRotation;
    expect(reconstructed.x, closeTo(transforms[1].worldRotation.x, 1e-12));
    expect(reconstructed.y, closeTo(transforms[1].worldRotation.y, 1e-12));
    expect(reconstructed.z, closeTo(transforms[1].worldRotation.z, 1e-12));
    expect(reconstructed.w, closeTo(transforms[1].worldRotation.w, 1e-12));
    expect(transforms[0].parentBoneIndex, isNull);
    expect(transforms[1].parentBoneIndex, 0);
    for (final transform in transforms) {
      expect(transform.localRotation.length, closeTo(1.0, 1e-12));
      expect(transform.worldRotation.length, closeTo(1.0, 1e-12));
      expect(transform.localRotation.x.isFinite, isTrue);
      expect(transform.localRotation.y.isFinite, isTrue);
      expect(transform.localRotation.z.isFinite, isTrue);
      expect(transform.localRotation.w.isFinite, isTrue);
      expect(transform.worldRotation.x.isFinite, isTrue);
      expect(transform.worldRotation.y.isFinite, isTrue);
      expect(transform.worldRotation.z.isFinite, isTrue);
      expect(transform.worldRotation.w.isFinite, isTrue);
    }
  });
}