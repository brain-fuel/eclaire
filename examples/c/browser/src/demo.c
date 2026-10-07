#include "elmish_clay.h"
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

static EclElement element(uint64_t id, EclKind kind, EclRole role, EclDirection direction,
                          EclSizing sizing, float width, float height, const char *text,
                          const char *name, uint64_t action, float font_size) {
    EclElement e = {0};
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
    size_t bytes = ecl_min_memory_size(32);
    clay_memory = malloc(bytes);
    if (!clay_memory) return ECL_ERR_CAPACITY;
    return (int32_t)ecl_init(clay_memory, bytes, 32, width, height, NULL, NULL, NULL, NULL);
}

int32_t demo_layout(float width, float height) {
    if (!clay_memory) return ECL_ERR_STATE;
    if (ecl_begin_frame(width, height, 0, 0, 0) != ECL_OK) return ECL_ERR_STATE;
    EclElement root = element(1, ECL_CONTAINER, ECL_ROLE_GROUP, ECL_COLUMN, ECL_GROW, width, height, NULL, "Counter showcase", 0, 16);
    root.padding = 24;
    root.gap = 16;
    if (ecl_push_element(&root) != ECL_OK) return ECL_ERR_CLAY;
    EclElement counter = element(2, ECL_TEXT, ECL_ROLE_NONE, ECL_COLUMN, ECL_FIT, 0, 0, "Count", "Counter", 0, 24);
    if (ecl_push_element(&counter) != ECL_OK || ecl_pop_element() != ECL_OK) return ECL_ERR_CLAY;
    EclElement actions = element(3, ECL_CONTAINER, ECL_ROLE_GROUP, ECL_ROW, ECL_GROW, 0, 0, NULL, "Counter actions", 0, 16);
    if (ecl_push_element(&actions) != ECL_OK) return ECL_ERR_CLAY;
    EclElement decrease = element(4, ECL_BUTTON, ECL_ROLE_BUTTON, ECL_COLUMN, ECL_FIT, 120, 44, "Decrease", "Decrease", 100, 16);
    if (ecl_push_element(&decrease) != ECL_OK || ecl_pop_element() != ECL_OK) return ECL_ERR_CLAY;
    EclElement increase = element(5, ECL_BUTTON, ECL_ROLE_BUTTON, ECL_COLUMN, ECL_FIT, 120, 44, "Increase", "Increase", 101, 16);
    if (ecl_push_element(&increase) != ECL_OK || ecl_pop_element() != ECL_OK || ecl_pop_element() != ECL_OK) return ECL_ERR_CLAY;
    EclElement checkbox = element(6, ECL_CHECKBOX, ECL_ROLE_CHECKBOX, ECL_ROW, ECL_FIT, 0, 28, "Show details", "Show details", 102, 16);
    if (ecl_push_element(&checkbox) != ECL_OK || ecl_pop_element() != ECL_OK) return ECL_ERR_CLAY;
    if (expanded_value) {
        EclElement details = element(7, ECL_CONTAINER, ECL_ROLE_GROUP, ECL_COLUMN, ECL_GROW, 0, 0, NULL, "Details", 0, 16);
        if (ecl_push_element(&details) != ECL_OK) return ECL_ERR_CLAY;
        EclElement text = element(8, ECL_TEXT, ECL_ROLE_NONE, ECL_COLUMN, ECL_FIT, 0, 0, "Clay solves layout; each host preserves control semantics.", "Details", 0, 16);
        if (ecl_push_element(&text) != ECL_OK || ecl_pop_element() != ECL_OK) return ECL_ERR_CLAY;
        EclElement image = element(9, ECL_IMAGE, ECL_ROLE_IMAGE, ECL_COLUMN, ECL_FIXED, 0, 220, NULL, "A starry sky above a mountain ridge", 0, 16);
        image.width = 0;
        if (ecl_push_element(&image) != ECL_OK || ecl_pop_element() != ECL_OK) return ECL_ERR_CLAY;
        EclElement scroll = element(10, ECL_SCROLL, ECL_ROLE_GROUP, ECL_COLUMN, ECL_FIXED, 0, 130, NULL, "Scrollable layout notes", 0, 16);
        if (ecl_push_element(&scroll) != ECL_OK) return ECL_ERR_CLAY;
        EclElement note = element(11, ECL_TEXT, ECL_ROLE_NONE, ECL_COLUMN, ECL_FIT, 0, 0, "Resize the browser to see the responsive card. Use Tab to move through the controls, then Space or Enter to activate them. The counter updates in a polite live region. The checkbox controls this details section. The image has alternative text, and this notes panel scrolls independently when its content is taller than the panel. All three runtimes use the same action IDs: 100 decreases, 101 increases, and 102 toggles details.", "Layout notes", 0, 16);
        if (ecl_push_element(&note) != ECL_OK || ecl_pop_element() != ECL_OK || ecl_pop_element() != ECL_OK || ecl_pop_element() != ECL_OK) return ECL_ERR_CLAY;
    }
    if (ecl_pop_element() != ECL_OK) return ECL_ERR_CLAY;
    return (int32_t)ecl_end_frame(1.0f / 60.0f);
}

int main(void) { return 0; }
