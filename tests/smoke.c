#include "elmish_clay.h"
#include <assert.h>
#include <stdlib.h>
int main(void){size_t n=ecl_min_memory_size(32);void *mem=malloc(n);assert(ecl_ir_version()==1);assert(ecl_init(mem,n,32,400,300,0,0,0,0)==ECL_OK);assert(ecl_begin_frame(400,300,0,0,0)==ECL_OK);EclElement root={.stable_id=1,.kind=ECL_CONTAINER,.direction=ECL_COLUMN,.sizing=ECL_GROW,.width=400,.height=300,.padding=8};assert(ecl_push_element(&root)==ECL_OK);assert(ecl_push_text(2,"Hello Elmish",18,0xffffffffu)==ECL_OK);assert(ecl_pop_element()==ECL_OK);assert(ecl_end_frame(1.f/60.f)==ECL_OK);assert(ecl_render_command_count()>0);free(mem);return 0;}
