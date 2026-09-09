#pragma once

#include <stdbool.h>
#include <stdint.h>

typedef struct input_bits_s {
    bool right: true;
    bool left: true;
    bool down: true;
    bool up: true;
    bool b: true;
    bool a: true;
    bool select: true;
    bool start: true;
} input_bits_t;

typedef struct kbd_s {
    input_bits_t bits;
    int8_t h_code;
} kbd_t;

typedef union {
    input_bits_t bits;
    uint8_t state;
} controller;

typedef struct __attribute__((__packed__)) {
    uint8_t version;
    bool swap_ab;
    uint8_t aspect_ratio;
    uint8_t ghosting;
    uint8_t palette;
    uint8_t save_slot;
    uint32_t rgb0;
    uint32_t rgb1;
    uint32_t rgb2;
    uint32_t rgb3;
    bool instant_ignition;
    uint8_t tv_system;
    uint8_t gray_lines;
    uint8_t gray_level;
    uint8_t demo_duration;
    bool color_mode;
} SETTINGS;

extern controller gamepad1;
extern SETTINGS settings;
