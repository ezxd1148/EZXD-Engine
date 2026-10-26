const std = @import("std");
const sdl = @import("sdl");

pub fn main(init: std.process.Init) !void {
    _ = init;

    std.debug.print("Starting SDL\n", .{});
    if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
        std.debug.print("SDL Init Failed: {s}\n", .{sdl.SDL_GetError()});
        return error.SdlInitializationFailed;
    }
    defer sdl.SDL_Quit();

    std.debug.print("SDL Initialized\n", .{});
    const window = sdl.SDL_CreateWindow(
        "EZXD Engine",
        1280,
        720,
        sdl.SDL_WINDOW_VULKAN | sdl.SDL_WINDOW_RESIZABLE,
    ) orelse {
        std.debug.print("SDL_CreateWindow failed: {s}\n", .{sdl.SDL_GetError()});
        return error.WindowCreationFailed;
    };
    defer sdl.SDL_DestroyWindow(window);

    std.debug.print("Window Created\n", .{});

    var running = true;
    var event: sdl.SDL_Event = undefined;

    while (running) {
        while (sdl.SDL_PollEvent(&event)) {
            if (event.type == sdl.SDL_EVENT_QUIT) {
                running = false;
            }
        }

        sdl.SDL_Delay(10);
    }
}
