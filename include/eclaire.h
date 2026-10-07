#ifndef ECLAIRE_H
#define ECLAIRE_H
#include <stddef.h>
#include <stdint.h>
#ifdef _WIN32
# ifdef ECLAIRE_BUILD
#  define ECLAIRE_API __declspec(dllexport)
# else
#  define ECLAIRE_API __declspec(dllimport)
# endif
#else
# define ECLAIRE_API __attribute__((visibility("default")))
#endif
#ifdef __cplusplus
extern "C" {
#endif
#define ECLAIRE_IR_VERSION 1u
typedef struct { float x,y,width,height; } EclaireRect;
typedef enum { ECLAIRE_ROW=0,ECLAIRE_COLUMN=1 } EclaireDirection;
typedef enum { ECLAIRE_FIXED=0,ECLAIRE_GROW=1,ECLAIRE_FIT=2 } EclaireSizing;
typedef enum { ECLAIRE_CONTAINER=0,ECLAIRE_TEXT=1,ECLAIRE_IMAGE=2,ECLAIRE_BUTTON=3,ECLAIRE_CHECKBOX=4,ECLAIRE_TEXT_INPUT=5,ECLAIRE_SCROLL=6 } EclaireKind;
typedef enum { ECLAIRE_ROLE_NONE=0,ECLAIRE_ROLE_GROUP=1,ECLAIRE_ROLE_BUTTON=2,ECLAIRE_ROLE_CHECKBOX=3,ECLAIRE_ROLE_TEXTBOX=4,ECLAIRE_ROLE_IMAGE=5 } EclaireRole;
typedef struct { uint32_t version; uint32_t struct_size; uint32_t element_count; uint32_t action_count; uint32_t diagnostics_count; } EclaireIrHeader;
typedef struct { uint64_t stable_id; uint64_t action_id; uint32_t parent_index; uint16_t kind; uint16_t role; uint32_t flags; EclaireRect rect; const char *text; const char *accessible_name; float width,height,padding,gap,font_size; uint8_t direction,sizing,checked,disabled; } EclaireElement;
typedef struct { uint32_t code; uint32_t element_index; uint32_t source_index; const char *message; } EclaireDiagnostic;
typedef struct { EclaireIrHeader header; const EclaireElement *elements; const EclaireDiagnostic *diagnostics; } EclaireDocument;
typedef enum { ECLAIRE_OK=0,ECLAIRE_ERR_ARGUMENT=1,ECLAIRE_ERR_STATE=2,ECLAIRE_ERR_CAPACITY=3,ECLAIRE_ERR_CLAY=4 } EclaireStatus;
typedef float (*EclaireMeasureTextFn)(const char *utf8,float font_size,void *user_data);
typedef void (*EclaireErrorFn)(uint32_t code,const char *message,void *user_data);
ECLAIRE_API uint32_t eclaire_ir_version(void);
ECLAIRE_API size_t eclaire_min_memory_size(uint32_t max_elements);
ECLAIRE_API EclaireStatus eclaire_init(void *memory,size_t memory_size,uint32_t max_elements,float width,float height,EclaireMeasureTextFn measure,void *measure_data,EclaireErrorFn error,void *error_data);
ECLAIRE_API EclaireStatus eclaire_begin_frame(float width,float height,float pointer_x,float pointer_y,int pointer_down);
ECLAIRE_API EclaireStatus eclaire_push_element(const EclaireElement *element);
ECLAIRE_API EclaireStatus eclaire_pop_element(void);
ECLAIRE_API EclaireStatus eclaire_push_text(uint64_t stable_id,const char *text,uint16_t font_size,uint32_t rgba);
ECLAIRE_API EclaireStatus eclaire_end_frame(float delta_time);
ECLAIRE_API uint32_t eclaire_render_command_count(void);
ECLAIRE_API int eclaire_render_command(uint32_t index,uint32_t *kind,EclaireRect *rect,uint32_t *rgba,const char **text);
ECLAIRE_API int eclaire_get_element_rect(uint64_t stable_id,EclaireRect *rect);
ECLAIRE_API uint32_t eclaire_last_error(void);
#ifdef __cplusplus
}
#endif
#endif
