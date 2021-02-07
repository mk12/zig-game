// Copyright 2021 Mitchell Kember. Subject to the MIT License.

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CAMetalLayer.h>

#define GLFW_INCLUDE_NONE
#define GLFW_EXPOSE_NATIVE_COCOA
#include <GLFW/glfw3.h>
#include <GLFW/glfw3native.h>

void *getMetalLayer(GLFWwindow *handle) {
    NSWindow *window = (NSWindow*)glfwGetCocoaWindow(handle);
    NSView *contentView = [window contentView];
    [contentView setWantsLayer:YES];
    CAMetalLayer *layer = [CAMetalLayer layer];
    [contentView setLayer:layer];
    return layer;
}
