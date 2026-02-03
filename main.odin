package main

// enable docking by default
//

import im "shared:odin-imgui"
import "shared:odin-imgui/imgui_impl_glfw"
import "shared:odin-imgui/imgui_impl_opengl3"
import gl "vendor:OpenGL"
import "vendor:glfw"


main :: proc() {
	assert(cast(bool)glfw.Init())

	defer glfw.Terminate()

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 2)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, 1)

	window := glfw.CreateWindow(1280, 720, "Patchman", nil, nil)

	assert(window != nil)

	defer glfw.DestroyWindow(window)

	glfw.MakeContextCurrent(window)
	glfw.SwapInterval(1) //vsync

	gl.load_up_to(3, 2, proc(p: rawptr, name: cstring) {
		(cast(^rawptr)p)^ = glfw.GetProcAddress(name)
	})

	im.CHECKVERSION()
	im.CreateContext()

	io := im.GetIO()
	io.ConfigFlags += {.NavEnableKeyboard, .DockingEnable, .ViewportsEnable}
	im.FontAtlas_AddFontFromFileTTF(io.Fonts, "./consolas.ttf", 16)

	style := im.GetStyle()
	style.WindowRounding = 0
	style.Colors[im.Col.WindowBg].w = 1

	im.StyleColorsLight()

	imgui_impl_glfw.InitForOpenGL(window, true)
	defer imgui_impl_glfw.Shutdown()

	imgui_impl_opengl3.Init("#version 150")
	defer imgui_impl_opengl3.Shutdown()

	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()

		imgui_impl_opengl3.NewFrame()
		imgui_impl_glfw.NewFrame()
		im.NewFrame()

		render_app(window)


		im.End()

		im.Render()

		display_w, display_h := glfw.GetFramebufferSize(window)
		gl.Viewport(0, 0, display_w, display_h)
		gl.ClearColor(0.2, 0.2, 0.4, 1)
		gl.Clear(gl.COLOR_BUFFER_BIT)
		imgui_impl_opengl3.RenderDrawData(im.GetDrawData())

		backup_current_window := glfw.GetCurrentContext()
		im.UpdatePlatformWindows()
		im.RenderPlatformWindowsDefault()
		glfw.MakeContextCurrent(backup_current_window)

		glfw.SwapBuffers(window)

	}
}
