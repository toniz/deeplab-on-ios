# Tensorflow-lite Deeplab RealTime 

## 1. Demo
![](http://www.ibbwhat.com/optimize1.gif)
![](http://www.ibbwhat.com/optimize2.gif)

## 2. Requirements:
- [Apple Developer Program Account](https://opencv.org/releases.html) (Simulator doesn’t have a camera)
- [Xcode 9.2](https://developer.apple.com/xcode/)
- [OpenCV 3.3.1 iOS Pack](https://opencv.org/releases.html)
- [Git LFS](https://git-lfs.github.com/)
- [Tensorflow-lite](https://www.tensorflow.org/lite/)
- any iOS device with a decent camera


## 3. Code reference

- Opencv 
  Example application made for [this post](https://medium.com/@dwayneforde/image-recognition-on-ios-with-swift-and-opencv-b5cf0667b79).

- Tensorflow 
  Example application made for [this post](https://www.tensorflow.org/lite/models/segmentation/overview)

- Model File: 
  PoseNet for pose estimation [download](https://storage.googleapis.com/download.tensorflow.org/models/tflite/gpu/multi_person_mobilenet_v1_075_float.tflite)
    (vision model that estimates the poses of a person(s) in image or video)

## 4. Installation:
```
git clone https://github.com/toniz/deeplab-on-ios.git
cd deeplab-on-ios/
pod install
open DeeplabOnIOS.xcworkspace
```


*   DeepLabv3+:
```
@inproceedings{deeplabv3plus2018,
  title={Encoder-Decoder with Atrous Separable Convolution for Semantic Image Segmentation},
  author={Liang-Chieh Chen and Yukun Zhu and George Papandreou and Florian Schroff and Hartwig Adam},
  booktitle={ECCV},
  year={2018}
}
```

