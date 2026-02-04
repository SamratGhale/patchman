package main

import "core:bytes"
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
	buff:         [2000]u8,
	req_buff:     [255]u8,
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
			if app.req_method == .Post {
				//Set request body
				bytes.buffer_reset(&app.req.body)

				cstr := cstring(&app.req_buff[0])
				str := strings.clone_from_cstring(cstr)

				bytes.buffer_write_string(&app.req.body, str)
			}
			app.res, _ = client.request(&app.req, string(cstring(&app.buff[0])))
			app.res_body, _, _ = client.response_body(&app.res)
			fmt.println(app.res)
			//client.response_destroy(&app.res, body)
			app.response_set = true
			//client.body_destroy(body, allocation)
		}
	}
	im.End()

	if im.Begin("Response") {

		if app.response_set {

			if im.BeginTabBar("Response tabs") {

				if im.BeginTabItem("Body", nil, {.Leading}) {
					#partial switch v in app.res_body {
					case client.Body_Plain:
						{
							cstr := strings.clone_to_cstring(v)
							im.TextWrapped(cstr)
							//im.InputTextMultiline("#", cstr, len(cstr), {-1, -1}, {.ReadOnly})
						}
					}
					im.EndTabItem()
				}

				if im.BeginTabItem("Headers", nil, {}) {

					if im.BeginTable("Headers", 2) {
						im.TableSetupColumn("Name")
						im.TableSetupColumn("Value")
						im.TableHeadersRow()

						im.TableNextRow()
						im.TableNextColumn()
						im.Text("Status code")
						im.TableNextColumn()
						im.Text(fmt.ctprintf("%s", app.res.status))

						for key, val in app.res.headers._kv {
							im.TableNextRow()
							im.TableNextColumn()
							im.Text(strings.unsafe_string_to_cstring(key))
							im.TableNextColumn()
							im.Text(strings.unsafe_string_to_cstring(val))
						}
					}
					im.EndTable()
					im.EndTabItem()
				}

				im.EndTabBar()
			}

		} else {
			im.TextWrapped("")
			//im.InputTextMultiline("#", "", 1000, {-min(f32), -min(f32)}, {.ReadOnly})
		}

	}
	im.End()

	if im.Begin("Request") {
		im.InputTextMultiline("#", cstring(&app.req_buff[0]), 2000, {-1, -1})

	}
	im.End()
}
