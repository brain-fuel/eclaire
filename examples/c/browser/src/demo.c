#include "eclaire.h"
#include <stdint.h>
#include <stdlib.h>

static int32_t count_value;
static int32_t expanded_value = 1;
static void *clay_memory;

int32_t demo_count(void) { return count_value; }
int32_t demo_expanded(void) { return expanded_value; }
void demo_action(uint32_t action_id) {
    switch (action_id) {
        case 100: count_value--; break;
        case 101: count_value++; break;
        case 102: expanded_value = !expanded_value; break;
        default: break;
    }
}

static EclaireElement element(uint64_t id, EclaireKind kind, EclaireRole role, EclaireDirection direction,
                          EclaireSizing sizing, float width, float height, const char *text,
                          const char *name, uint64_t action, float font_size) {
    EclaireElement e = {0};
    e.stable_id = id;
    e.action_id = action;
    e.kind = (uint16_t)kind;
    e.role = (uint16_t)role;
    e.direction = (uint8_t)direction;
    e.sizing = (uint8_t)sizing;
    e.width = width;
    e.height = height;
    e.padding = 0;
    e.gap = 12;
    e.font_size = font_size;
    e.text = text;
    e.accessible_name = name;
    return e;
}

int32_t demo_init(float width, float height) {
    size_t bytes = eclaire_min_memory_size(32);
    clay_memory = malloc(bytes);
    if (!clay_memory) return ECLAIRE_ERR_CAPACITY;
    return (int32_t)eclaire_init(clay_memory, bytes, 32, width, height, NULL, NULL, NULL, NULL);
}

int32_t demo_layout(float width, float height) {
    if (!clay_memory) return ECLAIRE_ERR_STATE;
    if (eclaire_begin_frame(width, height, 0, 0, 0) != ECLAIRE_OK) return ECLAIRE_ERR_STATE;
    EclaireElement root = element(1, ECLAIRE_CONTAINER, ECLAIRE_ROLE_GROUP, ECLAIRE_COLUMN, ECLAIRE_GROW, width, height, NULL, "Counter showcase", 0, 16);
    root.padding = 24;
    root.gap = 16;
    if (eclaire_push_element(&root) != ECLAIRE_OK) return ECLAIRE_ERR_CLAY;
    EclaireElement counter = element(2, ECLAIRE_TEXT, ECLAIRE_ROLE_NONE, ECLAIRE_COLUMN, ECLAIRE_FIT, 0, 0, "Count", "Counter", 0, 24);
    if (eclaire_push_element(&counter) != ECLAIRE_OK || eclaire_pop_element() != ECLAIRE_OK) return ECLAIRE_ERR_CLAY;
    EclaireElement actions = element(3, ECLAIRE_CONTAINER, ECLAIRE_ROLE_GROUP, ECLAIRE_ROW, ECLAIRE_GROW, 0, 0, NULL, "Counter actions", 0, 16);
    if (eclaire_push_element(&actions) != ECLAIRE_OK) return ECLAIRE_ERR_CLAY;
    EclaireElement decrease = element(4, ECLAIRE_BUTTON, ECLAIRE_ROLE_BUTTON, ECLAIRE_COLUMN, ECLAIRE_FIT, 120, 44, "Decrease", "Decrease", 100, 16);
    if (eclaire_push_element(&decrease) != ECLAIRE_OK || eclaire_pop_element() != ECLAIRE_OK) return ECLAIRE_ERR_CLAY;
    EclaireElement increase = element(5, ECLAIRE_BUTTON, ECLAIRE_ROLE_BUTTON, ECLAIRE_COLUMN, ECLAIRE_FIT, 120, 44, "Increase", "Increase", 101, 16);
    if (eclaire_push_element(&increase) != ECLAIRE_OK || eclaire_pop_element() != ECLAIRE_OK || eclaire_pop_element() != ECLAIRE_OK) return ECLAIRE_ERR_CLAY;
    EclaireElement checkbox = element(6, ECLAIRE_CHECKBOX, ECLAIRE_ROLE_CHECKBOX, ECLAIRE_ROW, ECLAIRE_FIT, 0, 28, "Show details", "Show details", 102, 16);
    if (eclaire_push_element(&checkbox) != ECLAIRE_OK || eclaire_pop_element() != ECLAIRE_OK) return ECLAIRE_ERR_CLAY;
    if (expanded_value) {
        EclaireElement details = element(7, ECLAIRE_CONTAINER, ECLAIRE_ROLE_GROUP, ECLAIRE_COLUMN, ECLAIRE_GROW, 0, 0, NULL, "Details", 0, 16);
        if (eclaire_push_element(&details) != ECLAIRE_OK) return ECLAIRE_ERR_CLAY;
        EclaireElement text = element(8, ECLAIRE_TEXT, ECLAIRE_ROLE_NONE, ECLAIRE_COLUMN, ECLAIRE_FIT, 0, 0, "Clay solves layout; each host preserves control semantics.", "Details", 0, 16);
        if (eclaire_push_element(&text) != ECLAIRE_OK || eclaire_pop_element() != ECLAIRE_OK) return ECLAIRE_ERR_CLAY;
        EclaireElement image = element(9, ECLAIRE_IMAGE, ECLAIRE_ROLE_IMAGE, ECLAIRE_COLUMN, ECLAIRE_FIXED, 0, 220, NULL, "A starry sky above a mountain ridge", 0, 16);
        image.width = 0;
        if (eclaire_push_element(&image) != ECLAIRE_OK || eclaire_pop_element() != ECLAIRE_OK) return ECLAIRE_ERR_CLAY;
        EclaireElement scroll = element(10, ECLAIRE_SCROLL, ECLAIRE_ROLE_GROUP, ECLAIRE_COLUMN, ECLAIRE_FIXED, 0, 130, NULL, "Scrollable layout notes", 0, 16);
        if (eclaire_push_element(&scroll) != ECLAIRE_OK) return ECLAIRE_ERR_CLAY;
        EclaireElement note = element(11, ECLAIRE_TEXT, ECLAIRE_ROLE_NONE, ECLAIRE_COLUMN, ECLAIRE_FIT, 0, 0, "Resize the browser to see the responsive card. Use Tab to move through the controls, then Space or Enter to activate them. The counter updates in a polite live region. The checkbox controls this details section. The image has alternative text, and this notes panel scrolls independently when its content is taller than the panel. All three runtimes use the same action IDs: 100 decreases, 101 increases, and 102 toggles details.", "Layout notes", 0, 16);
        if (eclaire_push_element(&note) != ECLAIRE_OK || eclaire_pop_element() != ECLAIRE_OK || eclaire_pop_element() != ECLAIRE_OK || eclaire_pop_element() != ECLAIRE_OK) return ECLAIRE_ERR_CLAY;
    }
    if (eclaire_pop_element() != ECLAIRE_OK) return ECLAIRE_ERR_CLAY;
    return (int32_t)eclaire_end_frame(1.0f / 60.0f);
}

int main(void) { return 0; }
