package main

import "core:fmt"
import "core:strings"
import http "shared:odin-http"
import client "shared:odin-http/client"
import im "shared:odin-imgui"
import "shared:odin-imgui/imgui_impl_glfw"
import "shared:odin-imgui/imgui_impl_opengl3"
import gl "vendor:OpenGL"
import "vendor:glfw"


App :: struct {
	buff:         [255]u8,
	req_method:   http.Method,
	req:          client.Request,
	res:          client.Response,
	res_body:     client.Body_Type,
	response_set: bool,
}

app: App

render_app :: proc(window: glfw.WindowHandle) {


	if im.Begin("Main Window") {
		if im.BeginCombo("Method ", fmt.ctprint(app.req_method), {.WidthFitPreview}) {
			for type in http.Method {
				if im.Selectable(fmt.ctprint(type), app.req_method == type) do app.req_method = type
			}
			im.EndCombo()
		}
		im.SameLine()

		if im.InputText("#", cstring(&app.buff[0]), 255, {.EnterReturnsTrue}) {
			client.request_init(&app.req, app.req_method)
			app.res, _ = client.request(&app.req, string(cstring(&app.buff[0])))
			app.res_body, _, _ = client.response_body(&app.res)
			//client.response_destroy(&app.res, body)
			app.response_set = true
			//client.body_destroy(body, allocation)
		}


		if app.response_set {
			#partial switch v in app.res_body {
			case client.Body_Plain:
				{
					im.Text(strings.clone_to_cstring(v))
				}
			}
		}

	}
}
