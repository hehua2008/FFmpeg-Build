#ifndef TVAI_H
#define TVAI_H
#include "tvai_data.h"

#ifdef _WIN32
#define DECL_EXPORT __declspec(dllexport)
#else
#define DECL_EXPORT
#endif

#ifdef __cplusplus
extern "C" {
#endif
    DECL_EXPORT void tvai_set_logging(int status);
    DECL_EXPORT void* tvai_create(VideoProcessorInfo* pVideoProcessorInfo);
    DECL_EXPORT int tvai_process(void* pProcessor, TVAIBuffer* pBuffer);
    DECL_EXPORT void tvai_stabilize_get_output_size(void* pProcessor, int* pWidth, int* pHeight);
    DECL_EXPORT int tvai_device_list(char *deviceListString, int n);
    DECL_EXPORT int tvai_model_list(char* model, int type, char *modelListString, int n);
    DECL_EXPORT int tvai_scale_list(char* model, int scale, char *scaleListString, int n);
    DECL_EXPORT int tvai_output_frame(void* pProcessor, TVAIBuffer* pBuffer);
    DECL_EXPORT int tvai_output_params(void* pProcessor, TVAIBuffer* pBuffer);
    DECL_EXPORT int tvai_output_count(void* pProcessor);
    DECL_EXPORT int tvai_frames_pending(void* pProcessor);
    DECL_EXPORT void tvai_end_stream(void* pProcessor);
    DECL_EXPORT unsigned int tvai_remaining_frames(void* pProcessor);
    DECL_EXPORT void tvai_update_parameters(void* pProcessor, const float* parameters, int count);
    DECL_EXPORT void tvai_destroy(void* pProcessor);
    DECL_EXPORT void tvai_wait(long milliseconds);
    DECL_EXPORT int tvai_vp_name(char *model, unsigned int index, char* vpName);
    DECL_EXPORT void tvai_set_logging_path(const char *path);
    DECL_EXPORT int tvai_setup_model_manager(char* configPath, char* dataPath, int enableDownload);
    DECL_EXPORT int tvai_owns_app();
    DECL_EXPORT void tvai_disable_trt_ov();
    DECL_EXPORT void tvai_report_event(const char* eventName, const char* version);

#ifdef __cplusplus
}
#endif

#endif // TVAI_H
