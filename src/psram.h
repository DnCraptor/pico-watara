#pragma once

#include <stddef.h>
#include <stdbool.h>
#include <stdint.h>

#define WATARA_PSRAM_BASE ((uintptr_t)0x11000000u)
#define WATARA_PSRAM_MAX_SIZE (16u * 1024u * 1024u)

#ifdef __cplusplus
extern "C" {
#endif

bool watara_psram_init(void);
bool watara_psram_available(void);
size_t watara_psram_size(void);
void watara_psram_reclock(void);

#ifdef __cplusplus
}
#endif
