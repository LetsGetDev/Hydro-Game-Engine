package core

import im "Imgui"
import "Imgui/imgui_impl_glfw"
import "Imgui/imgui_impl_opengl3"
import "vendor:glfw"
import gl "vendor:OpenGL"
import "core:c"

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
	imgui_impl_opengl3.Init("#version 330")
}

render_editor::proc(){

	imgui_impl_opengl3.NewFrame()
	imgui_impl_glfw.NewFrame()
	im.NewFrame()


	items:cstring

	current:c.int = 1
	store:f32
	if im.Begin("Propeties"){
		im.Text("Select Object")
		im.Text("//Position//")
		im.InputFloat("X",&store)
		im.InputFloat("Y",&store)
		im.InputFloat("Z",&store)

	}
	
	im.End()

    
	
	im.Render()
    imgui_impl_opengl3.RenderDrawData(im.GetDrawData())


    when !DISABLE_DOCKING {
		backup_current_window := glfw.GetCurrentContext()
		im.UpdatePlatformWindows()
		im.RenderPlatformWindowsDefault()
		glfw.MakeContextCurrent(backup_current_window)
	}
}