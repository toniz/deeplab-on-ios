//
//  NostalgiaCamera.m
//  DeeplabOnIOS
//
//  Created by Dwayne Forde on 2017-12-23.
//

#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgcodecs/ios.h>
#include "NostalgiaCamera.h"
#include "TfliteWrapper.h"

using namespace std;
using namespace cv;


@interface NostalgiaCamera () <CvVideoCameraDelegate>
@end


@implementation NostalgiaCamera
{
    UIViewController<NostalgiaCameraDelegate> * delegate;
    UIImageView * imageView;
    CvVideoCamera * videoCamera;
    TfliteWrapper  *tfLiteWrapper;
}

- (id)initWithController:(UIViewController<NostalgiaCameraDelegate>*)c andImageView:(UIImageView*)iv
{
    delegate = c;
    imageView = iv;
    
    videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView]; // Init with the UIImageView from the ViewController
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack; // Use the back camera
    videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait; // Ensure proper orientation
    videoCamera.rotateVideo = YES; // Ensure proper orientation
    videoCamera.defaultFPS = 30; // How often 'processImage' is called, adjust based on the amount/complexity of images
    videoCamera.delegate = self;
    
    tfLiteWrapper = [[TfliteWrapper alloc]init];
    tfLiteWrapper = [tfLiteWrapper initWithModelFileName:@"deeplabv3_257_mv_gpu"];
    if(![tfLiteWrapper setUpModelAndInterpreter])
    {
        NSLog(@"Failed To Load Model");
        return self;
    }

    return self;
}

- (void)processImage:(cv::Mat &)frame {
    cv::Mat small;
    cv::resize(frame, small, cv::Size(257, 257), 0, 0, CV_INTER_LINEAR);
    float_t *input = [tfLiteWrapper inputTensortFloatAtIndex:0];
    //NSLog(@"Input: %f", *input);

    //BGRA2RGB
    int inputCnt=0;
    for (int row = 0; row < small.rows; row++)
    {
        uchar* data = small.ptr(row);
        for (int col = 0; col < small.cols; col++)
        {
            input[inputCnt++] = (float)data[col * 4 + 2]/255.0; // Red
            input[inputCnt++] = (float)data[col * 4 + 1]/255.0; // Green
            input[inputCnt++] = (float)data[col * 4 ]/255.0; // Bule
        }
    }

    if([tfLiteWrapper invokeInterpreter])
    {
        float_t *output = [tfLiteWrapper outputTensorAtIndex:0];
        for (int row = 0; row < small.rows; row++)
        {
            uchar* data = small.ptr(row);
            int rowBegin = row * small.cols * 21;
            for (int col = 0; col < small.cols; col++)
            {
                int colBegin = rowBegin + col  * 21;
                int maxIndex = 0;
                float maxValue = output[colBegin];
                for(int chan=1; chan < 21; chan++)
                {
                    if(output[colBegin+chan] > maxValue)
                    {
                        maxValue = output[colBegin+chan];
                        maxIndex = chan;
                    }
                }

                if(maxIndex == 15) // PERSON
                {
                    data[col * 4 + 3] = 0;
                    data[col * 4 + 2] = 0;
                    data[col * 4 + 1] = 0;
                    data[col * 4] = 0;
                }
                else
                {
                    data[col * 4 + 3] = 255;
                    data[col * 4 + 2] = 255;
                    data[col * 4 + 1] = 255;
                    data[col * 4] = 255;
                }
            }
        }
    }
    
    Mat bigMask;
    cv::resize(small, bigMask, cv::Size(frame.cols, frame.rows), 0, 0, CV_INTER_LINEAR);

    // Draw Contour
    /*
    Mat grey;
    cvtColor(bigMask, grey, CV_BGR2GRAY); //CV_8UC1
    std::vector<std::vector<cv::Point> > contours;
    findContours(grey, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    for( size_t i = 0; i < contours.size(); i++ )
    {
        std::vector<cv::Point> approx;
        cv::approxPolyDP(Mat(contours[i]), approx, arcLength(Mat(contours[i]), true)*0.02, true);
        int n = (int)approx.size();
        const cv::Point* p = &approx[0];
        cv::polylines(frame, &p, &n, 1, true, Scalar(0,255,0));
    }
    */
    cv::bitwise_or(frame, bigMask, frame);
    return;
}

- (void)start
{
    [videoCamera start];
}

- (void)stop
{
    [videoCamera stop];
}

@end
