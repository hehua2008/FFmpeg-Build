#ifndef TVAI_DATA_H
#define TVAI_DATA_H

#define TVAI_MAX_PARAMETER_COUNT 20
#define TVAI_MAX_OPTIONS_COUNT 5
#define TVAI_PROCESSOR_NAME_SIZE 32

#define SS << " " <<

#ifdef __cplusplus
extern "C" {
#endif

    typedef enum {
      ModelTypeNone,
      ModelTypeUpscaling = 1,
      ModelTypeFrameInterpolation = 2,
      ModelTypeParameterEstimation = 3,
      ModelTypeCamPoseEstimation = 4,
      ModelTypeStabilization = 5,
      ModelTypeCount
    } ModelType;

    typedef enum {
      TVAIPixelFormatNone,
      TVAIPixelFormatRGB8,
      TVAIPixelFormatRGB16,
      TVAIPixelFormatARGB8,
      TVAIPixelFormatARGB16,
      TVAIPixelFormatRGBA8,
      TVAIPixelFormatRGBA16,
      TVAIPixelFormatRGBA32F,
      TVAIPixelFormatVFRGBA32F
    } TVAIPixelFormat;

    typedef struct {
        int index;
        unsigned int extraThreadCount;
        double maxMemory;
    } DeviceSetting;


    typedef struct {
        char *modelName;
        char processorName[TVAI_PROCESSOR_NAME_SIZE];
        int inputWidth, inputHeight, scale;
        TVAIPixelFormat pixelFormat;
        double timebase, framerate;
        DeviceSetting device;
        int preflight;
        int canDownloadModel;
    } BasicProcessorInfo;

    typedef struct {
        BasicProcessorInfo basic;
        int outputWidth, outputHeight;
        int frameCount;
        char *options[TVAI_MAX_OPTIONS_COUNT];
        float modelParameters[TVAI_MAX_PARAMETER_COUNT];
    } VideoProcessorInfo;


    typedef struct {
        unsigned char *pBuffer;
        int lineSize;
        long long pts;
        long frameNo;
        long long duration;
    } TVAIBuffer;

#ifdef __cplusplus
}
#endif

#endif // TVAI_DATA_H
