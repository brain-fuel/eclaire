#include "eclaire.h"
#include <assert.h>
#include <stdlib.h>
int main(void){size_t n=eclaire_min_memory_size(32);void *mem=malloc(n);assert(eclaire_ir_version()==1);assert(eclaire_init(mem,n,32,400,300,0,0,0,0)==ECLAIRE_OK);assert(eclaire_begin_frame(400,300,0,0,0)==ECLAIRE_OK);EclaireElement root={.stable_id=1,.kind=ECLAIRE_CONTAINER,.direction=ECLAIRE_COLUMN,.sizing=ECLAIRE_GROW,.width=400,.height=300,.padding=8};assert(eclaire_push_element(&root)==ECLAIRE_OK);assert(eclaire_push_text(2,"Hello Eclaire",18,0xffffffffu)==ECLAIRE_OK);assert(eclaire_pop_element()==ECLAIRE_OK);assert(eclaire_end_frame(1.f/60.f)==ECLAIRE_OK);assert(eclaire_render_command_count()>0);free(mem);return 0;}
