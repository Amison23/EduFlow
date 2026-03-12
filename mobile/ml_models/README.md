# Machine Learning Models (ml_models)

This directory is the dedicated location for TensorFlow Lite (`.tflite`) models used by the EduFlow mobile application for offline intelligent features.

## Current Status
The application currently uses a **Heuristic Adaptation** approach located in `lib/services/tflite_quiz_service.dart`. While the "brain" behaves intelligently by adjusting topic weights based on performance, it is currently using a mock implementation until a formal model is deployed here.

## Integration Instructions

To integrate a production-ready ML model for adaptive learning:

1.  **Add Model File**: Place your trained `quiz_adapter.tflite` (or similar) file into this directory.
2.  **Verify Assets**: Ensure the model is registered in the `pubspec.yaml` file under the `assets` section:
    ```yaml
    flutter:
      assets:
        - ml_models/quiz_adapter.tflite
    ```
3.  **Enable Code**: Open `lib/services/tflite_quiz_service.dart` and uncomment the model loading logic in the `init()` method:
    ```dart
    Future<void> init() async {
      _model = await Tflite.loadModel(
        modelPath: 'assets/ml_models/quiz_adapter.tflite',
        labels: 'assets/ml_models/labels.txt', // if applicable
      );
    }
    ```
4.  **Update Inference**: Replace the simplified `updateTopicWeight` logic with actual model inference calls.

## Why Offline ML?
EduFlow is designed for learners in displacement contexts where internet access is often expensive or unavailable. By running ML models locally on the device (Edge AI), we provide:
- **Zero Data Cost**: Intelligent adaptation without backend calls.
- **Privacy**: Learner performance data stays on the device.
- **Instant Response**: No latency during quizzes or lesson selection.
