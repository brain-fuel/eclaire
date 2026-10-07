#ifndef ELMISH_CLAY_H
#define ELMISH_CLAY_H
#include <stddef.h>
#include <stdint.h>
#ifdef _WIN32
# ifdef ECL_BUILD
#  define ECL_API __declspec(dllexport)
# else
#  define ECL_API __declspec(dllimport)
# endif
#else
# define ECL_API __attribute__((visibility("default")))
#endif
#ifdef __cplusplus
extern "C" {
#endif
#define ECL_IR_VERSION 1u
typedef struct { float x,y,width,height; } EclRect;
typedef enum { ECL_ROW=0,ECL_COLUMN=1 } EclDirection;
typedef enum { ECL_FIXED=0,ECL_GROW=1,ECL_FIT=2 } EclSizing;
typedef enum { ECL_CONTAINER=0,ECL_TEXT=1,ECL_IMAGE=2,ECL_BUTTON=3,ECL_CHECKBOX=4,ECL_TEXT_INPUT=5,ECL_SCROLL=6 } EclKind;
typedef enum { ECL_ROLE_NONE=0,ECL_ROLE_GROUP=1,ECL_ROLE_BUTTON=2,ECL_ROLE_CHECKBOX=3,ECL_ROLE_TEXTBOX=4,ECL_ROLE_IMAGE=5 } EclRole;
typedef struct { uint32_t version; uint32_t struct_size; uint32_t element_count; uint32_t action_count; uint32_t diagnostics_count; } EclIrHeader;
typedef struct { uint64_t stable_id; uint64_t action_id; uint32_t parent_index; uint16_t kind; uint16_t role; uint32_t flags; EclRect rect; const char *text; const char *accessible_name; float width,height,padding,gap,font_size; uint8_t direction,sizing,checked,disabled; } EclElement;
typedef struct { uint32_t code; uint32_t element_index; uint32_t source_index; const char *message; } EclDiagnostic;
typedef struct { EclIrHeader header; const EclElement *elements; const EclDiagnostic *diagnostics; } EclDocument;
typedef enum { ECL_OK=0,ECL_ERR_ARGUMENT=1,ECL_ERR_STATE=2,ECL_ERR_CAPACITY=3,ECL_ERR_CLAY=4 } EclStatus;
typedef float (*EclMeasureTextFn)(const char *utf8,float font_size,void *user_data);
typedef void (*EclErrorFn)(uint32_t code,const char *message,void *user_data);
ECL_API uint32_t ecl_ir_version(void);
ECL_API size_t ecl_min_memory_size(uint32_t max_elements);
ECL_API EclStatus ecl_init(void *memory,size_t memory_size,uint32_t max_elements,float width,float height,EclMeasureTextFn measure,void *measure_data,EclErrorFn error,void *error_data);
ECL_API EclStatus ecl_begin_frame(float width,float height,float pointer_x,float pointer_y,int pointer_down);
ECL_API EclStatus ecl_push_element(const EclElement *element);
ECL_API EclStatus ecl_pop_element(void);
ECL_API EclStatus ecl_push_text(uint64_t stable_id,const char *text,uint16_t font_size,uint32_t rgba);
ECL_API EclStatus ecl_end_frame(float delta_time);
ECL_API uint32_t ecl_render_command_count(void);
ECL_API int ecl_render_command(uint32_t index,uint32_t *kind,EclRect *rect,uint32_t *rgba,const char **text);
ECL_API int ecl_get_element_rect(uint64_t stable_id,EclRect *rect);
ECL_API uint32_t ecl_last_error(void);
#ifdef __cplusplus
}
#endif
#endif
