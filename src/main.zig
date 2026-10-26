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

    std.debug.print("Video driver: {s}\n", .{sdl.SDL_GetCurrentVideoDriver()}); // Im using wayland

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

    const renderer = sdl.SDL_CreateRenderer(window, null) orelse {
        std.debug.print("SDL_CreateRenderer failed: {s}\n", .{sdl.SDL_GetError()});
        return error.RendererCreationFailed;
    };
    defer sdl.SDL_DestroyRenderer(renderer);

    std.debug.print("Window Created\n", .{});

    var running = true;
    var event: sdl.SDL_Event = undefined;

    while (running) {
        while (sdl.SDL_PollEvent(&event)) {
            if (event.type == sdl.SDL_EVENT_QUIT) {
                running = false;
            }
        }

        if (!sdl.SDL_SetRenderDrawColor(renderer, 0, 0, 255, 255)) {
            std.debug.print("Error while rending color {s}\n", .{sdl.SDL_GetError()});
        }

        if (!sdl.SDL_RenderClear(renderer)) {
            std.debug.print("Error while Clearing Render: {s}\n", .{sdl.SDL_GetError()});
        }

        if (!sdl.SDL_RenderPresent(renderer)) {
            std.debug.print("Error while presenting render: {s}\n", .{sdl.SDL_GetError()});
        }
    }
}
