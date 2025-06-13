package core

import im "Imgui"
import "Imgui/imgui_impl_glfw"
import "Imgui/imgui_impl_opengl3"
import "vendor:glfw"
import gl "vendor:OpenGL"

DISABLE_DOCKING :: #config(DISABLE_DOCKING, false)


configure_editor::proc(window:glfw.WindowHandle){
    im.CHECKVERSION()
	im.CreateContext()
	io := im.GetIO()
	io.ConfigFlags += {.NavEnableKeyboard, .NavEnableGamepad}
	when !DISABLE_DOCKING {
		io.ConfigFlags += {.DockingEnable}
		io.ConfigFlags += {.ViewportsEnable}

		style := im.GetStyle()
		style.WindowRounding = 0
		style.Colors[im.Col.WindowBg].w = 1
	}

	im.StyleColorsDark()

	imgui_impl_glfw.InitForOpenGL(window, true)
	imgui_impl_opengl3.Init("#version 150")
}

render_editor::proc(){

	imgui_impl_opengl3.NewFrame()
	imgui_impl_glfw.NewFrame()
	im.NewFrame()

	im.ShowDemoWindow()




    im.Render()
    imgui_impl_opengl3.RenderDrawData(im.GetDrawData())


    when !DISABLE_DOCKING {
		backup_current_window := glfw.GetCurrentContext()
		im.UpdatePlatformWindows()
		im.RenderPlatformWindowsDefault()
		glfw.MakeContextCurrent(backup_current_window)
	}
}