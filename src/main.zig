const std = @import("std");
const sdl = @import("sdl");
// const vk = @import("vulkan");

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
        sdl.SDL_WINDOW_VULKAN | sdl.SDL_WINDOW_RESIZABLE, // called vulkan here
    ) orelse {
        std.debug.print("SDL_CreateWindow failed: {s}\n", .{sdl.SDL_GetError()});
        return error.WindowCreationFailed;
    };
    defer sdl.SDL_DestroyWindow(window);

    // vulkan renderer
    var extension_count: u32 = 0;

    const extension_names = sdl.SDL_Vulkan_GetInstanceExtensions(&extension_count);

    if (extension_names == null) {
        std.debug.print("Vulkan failed: {s}\n", .{
            sdl.SDL_GetError(),
        });
        return error.VulkanExtensionsUnavailable;
    }

    for (0..extension_count) |i| {
        std.debug.print("Required extension: {s}\n", .{
            extension_names[i],
        });
        if (!sdl.SDL_Vulkan_LoadLibrary(extension_names[i])) {
            std.debug.print("Library Load error: {s}\n", .{sdl.SDL_GetError()});
        }
    }

    //const renderer = sdl.SDL_CreateRenderer(window, null) orelse {
    //    std.debug.print("SDL_CreateRenderer failed: {s}\n", .{sdl.SDL_GetError()});
    //    return error.RendererCreationFailed;
    //};
    //defer sdl.SDL_DestroyRenderer(renderer);

    std.debug.print("Window Created\n", .{});

    //const count_instance_extensions: [*c]u32 = undefined;
    //const instance_extensions = sdl.SDL_Vulkan_GetInstanceExtensions(count_instance_extensions);
    //if (instance_extensions == null) {
    //    std.debug.print("Error on vulkan instance: {s}\n", .{sdl.SDL_GetError()});
    //}

    // from here
    //const count_extensions = count_instance_extensions + 1;
    //const extensions = sdl.SDL_malloc(count_extensions * @sizeOf(c_char));
    //extensions[0] = sdl.VK_EXT_DEBUG_REPORT_EXTENSION_NAME;
    //sdl.SDL_memcpy(&extensions[1], instance_extensions, count_instance_extensions * @sizeOf(c_char));

    //const create_info = struct {};
    //create_info.enabledExtensionCount = count_extensions;
    //create_info.ppEnabledExtensionNames = extensions;

    // checkpoint 1 error here trying to research how to do it in zig idiomatic
    // const instance =
    // to here

    var running = true;
    var event: sdl.SDL_Event = undefined;

    while (running) {
        while (sdl.SDL_PollEvent(&event)) {
            if (event.type == sdl.SDL_EVENT_QUIT) {
                running = false;
            }
        }

        if (!sdl.SDL_Vulkan_CreateSurface(window, @constCast(&sdl.VkInstance), null, @constCast(&sdl.VK_KHR_surface))) {
            std.debug.print("Error on creating surface: {s}\n", .{sdl.SDL_GetError()});
        }

        //if (!sdl.SDL_SetRenderDrawColor(renderer, 0, 0, 255, 255)) {
        //    std.debug.print("Error while rending color {s}\n", .{sdl.SDL_GetError()});
        //}

        //if (!sdl.SDL_RenderClear(renderer)) {
        //    std.debug.print("Error while Clearing Render: {s}\n", .{sdl.SDL_GetError()});
        //}

        //if (!sdl.SDL_RenderPresent(renderer)) {
        //    std.debug.print("Error while presenting render: {s}\n", .{sdl.SDL_GetError()});
        //}
        //
        sdl.SDL_Delay(10);
    }
}

fn createInstance() !sdl.VkInstance {
    var extension_count: u32 = 0;
    const extensions = sdl.SDL_Vulkan_GetInstanceExtensions(&extension_count);

    if (extensions == null) {
        std.debug.print("Error on getting instance: {s}\n", .{sdl.SDL_GetError()});
        return error.VulkanExtensionsUnavailable;
    }

    var app_info = std.mem.zeroes(sdl.VkApplicationInfo);
    app_info.sType = sdl.VK_STRUCTURE_TYPE_APPLICATION_INFO;
    app_info.pApplicationName = "EZXD Fun Game";
    app_info.pEngineName = "EZXD Engine";
    app_info.apiVersion = sdl.VK_API_VERSION_1_3;

    var create_info = std.mem.zeroes(sdl.VkInstanceInfo);
    create_info.sType = sdl.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    create_info.pApplicationInfo = &app_info;
    create_info.enabledExtensionCount = extension_count;
    create_info.ppEnabledExtensionNames = extensions;

    var instance: sdl.VkInstance = undefined;

    const result = sdl.vkCreateInstance(&create_info, null, &instance);

    if (result != sdl.VK_SUCCESS) {
        std.debug.print("vkCreateInstance failed: {d}\n", .{result});
        return error.InstanceCreationFailed;
    }

    return instance;
}
