function osdmodulesbuild()

	removeflags {
		"SingleOutputDir",
	}

	options {
		"ForceCPP",
	}

	files {
		MAME_DIR .. "src/osd/modules/lib/osdobj_common.c",
		MAME_DIR .. "src/osd/modules/debugger/none.c",
		MAME_DIR .. "src/osd/modules/debugger/debugint.c",
		MAME_DIR .. "src/osd/modules/debugger/debugwin.c",
		MAME_DIR .. "src/osd/modules/debugger/debugqt.c",
		MAME_DIR .. "src/osd/modules/font/font_sdl.c",
		MAME_DIR .. "src/osd/modules/font/font_windows.c",
		MAME_DIR .. "src/osd/modules/font/font_osx.c",
		MAME_DIR .. "src/osd/modules/font/font_none.c",
		MAME_DIR .. "src/osd/modules/netdev/taptun.c",
		MAME_DIR .. "src/osd/modules/netdev/pcap.c",
		MAME_DIR .. "src/osd/modules/netdev/none.c",
		MAME_DIR .. "src/osd/modules/midi/portmidi.c",
		MAME_DIR .. "src/osd/modules/midi/none.c",
		MAME_DIR .. "src/osd/modules/sound/js_sound.c",
		MAME_DIR .. "src/osd/modules/sound/direct_sound.c",
		MAME_DIR .. "src/osd/modules/sound/sdl_sound.c",
		MAME_DIR .. "src/osd/modules/sound/none.c",
	}

	if _OPTIONS["targetos"]=="windows" then
		includedirs {
			MAME_DIR .. "3rdparty/winpcap/Include",
		}
	end

	if _OPTIONS["NO_OPENGL"]=="1" then
		defines {
			"USE_OPENGL=0",
		}
	else
		files {
			MAME_DIR .. "src/osd/modules/render/drawogl.c",
			MAME_DIR .. "src/osd/modules/opengl/gl_shader_tool.c",
			MAME_DIR .. "src/osd/modules/opengl/gl_shader_mgr.c",
		}
		defines {
			"USE_OPENGL=1",
		}
		if _OPTIONS["USE_DISPATCH_GL"]=="1" then
			defines {
				"USE_DISPATCH_GL=1",
			}
		end
	end

	if USE_BGFX == 1 then
		files {
			MAME_DIR .. "src/osd/modules/render/drawbgfx.c",
		}
		defines {
			"USE_BGFX"
		}
		includedirs {
			MAME_DIR .. "3rdparty/bgfx/include",
			MAME_DIR .. "3rdparty/bx/include",
		}
	end

	if _OPTIONS["NO_USE_MIDI"]=="1" then
		defines {
			"NO_USE_MIDI",
		}
	end

	if _OPTIONS["USE_QTDEBUG"]=="1" then
		files {
			MAME_DIR .. "src/osd/modules/debugger/qt/debuggerview.c",
			MAME_DIR .. "src/osd/modules/debugger/qt/windowqt.c",
			MAME_DIR .. "src/osd/modules/debugger/qt/logwindow.c",
			MAME_DIR .. "src/osd/modules/debugger/qt/dasmwindow.c",
			MAME_DIR .. "src/osd/modules/debugger/qt/mainwindow.c",
			MAME_DIR .. "src/osd/modules/debugger/qt/memorywindow.c",
			MAME_DIR .. "src/osd/modules/debugger/qt/breakpointswindow.c",
			MAME_DIR .. "src/osd/modules/debugger/qt/deviceswindow.c",
			MAME_DIR .. "src/osd/modules/debugger/qt/deviceinformationwindow.c",
			GEN_DIR .. "osd/modules/debugger/qt/debuggerview.moc.c",
			GEN_DIR .. "osd/modules/debugger/qt/windowqt.moc.c",
			GEN_DIR .. "osd/modules/debugger/qt/logwindow.moc.c",
			GEN_DIR .. "osd/modules/debugger/qt/dasmwindow.moc.c",
			GEN_DIR .. "osd/modules/debugger/qt/mainwindow.moc.c",
			GEN_DIR .. "osd/modules/debugger/qt/memorywindow.moc.c",
			GEN_DIR .. "osd/modules/debugger/qt/breakpointswindow.moc.c",
			GEN_DIR .. "osd/modules/debugger/qt/deviceswindow.moc.c",
			GEN_DIR .. "osd/modules/debugger/qt/deviceinformationwindow.moc.c",
		}
		defines {
			"USE_QTDEBUG=1",
		}
		if _OPTIONS["targetos"]=="windows" then
			configuration { "mingw*" }
				buildoptions {
					"-I$(shell qmake -query QT_INSTALL_HEADERS)",
				}
			configuration { }
		elseif _OPTIONS["targetos"]=="macosx" then
			buildoptions {
				"-F" .. string.gsub(os.outputof("qmake -query QT_INSTALL_LIBS"), '[\r\n]+', ''),
			}
		else
			buildoptions {
				string.gsub(os.outputof("pkg-config --cflags Qt"), '[\r\n]+', ' '),
			}
		end
	else
		defines {
			"USE_QTDEBUG=0",
		}
	end

end


function osdmodulestargetconf()

	if _OPTIONS["NO_OPENGL"]~="1" then
		if _OPTIONS["targetos"]=="macosx" then
			links {
				"OpenGL.framework",
			}
		elseif _OPTIONS["USE_DISPATCH_GL"]~="1" then
			if _OPTIONS["targetos"]=="windows" then
				links {
					"opengl32",
				}
			else
				links {
					"GL",
				}
			end
		end
	end

	if _OPTIONS["NO_USE_MIDI"]~="1" then
		if _OPTIONS["targetos"]=="linux" then
			linkoptions {
				string.gsub(os.outputof("pkg-config --libs alsa"), '[\r\n]+', ' '),
			}
		elseif _OPTIONS["targetos"]=="macosx" then
			links {
				"CoreAudio.framework",
				"CoreMIDI.framework",
			}
		end
	end

	if _OPTIONS["USE_QTDEBUG"]=="1" then
		if _OPTIONS["targetos"]=="windows" then
			linkoptions {
				"-L$(shell qmake -query QT_INSTALL_LIBS)",
			}
			links {
				"qtmain",
				"QtGui4",
				"QtCore4",
			}
		elseif _OPTIONS["targetos"]=="macosx" then
			linkoptions {
				"-F" .. string.gsub(os.outputof("qmake -query QT_INSTALL_LIBS"), '[\r\n]+', ''),
			}
			links {
				"QtCore.framework",
				"QtGui.framework",
			}
		else
			linkoptions {
				string.gsub(os.outputof("pkg-config --libs QtGui"), '[\r\n]+', ' '),
			}
		end
	end

end


newoption {
	trigger = "DONT_USE_NETWORK",
	description = "Disable network access",
}

newoption {
	trigger = "NO_OPENGL",
	description = "Disable use of OpenGL",
	allowed = {
		{ "0",  "Enable OpenGL"  },
		{ "1",  "Disable OpenGL" },
	},
}

if not _OPTIONS["NO_OPENGL"] then
	if _OPTIONS["targetos"]=="os2" then
		_OPTIONS["NO_OPENGL"] = "1"
	else
		_OPTIONS["NO_OPENGL"] = "0"
	end
end

newoption {
	trigger = "USE_DISPATCH_GL",
	description = "Use GL-dispatching",
	allowed = {
		{ "0",  "Link to OpenGL library"  },
		{ "1",  "Use GL-dispatching"      },
	},
}

if not _OPTIONS["USE_DISPATCH_GL"] then
	if USE_BGFX == 1 then
		_OPTIONS["USE_DISPATCH_GL"] = "0"
	else
		_OPTIONS["USE_DISPATCH_GL"] = "1"
	end
end

newoption {
	trigger = "NO_USE_MIDI",
	description = "Disable MIDI I/O",
	allowed = {
		{ "0",  "Enable MIDI"  },
		{ "1",  "Disable MIDI" },
	},
}

if not _OPTIONS["NO_USE_MIDI"] then
	if _OPTIONS["targetos"]=="freebsd" or _OPTIONS["targetos"]=="openbsd" or _OPTIONS["targetos"]=="netbsd" or _OPTIONS["targetos"]=="solaris" or _OPTIONS["targetos"]=="haiku" or _OPTIONS["targetos"] == "emscripten" or _OPTIONS["targetos"] == "os2" then
		_OPTIONS["NO_USE_MIDI"] = "1"
	else
		_OPTIONS["NO_USE_MIDI"] = "0"
	end
end

newoption {
	trigger = "USE_QTDEBUG",
	description = "Use QT debugger",
	allowed = {
		{ "0",  "Don't use Qt debugger"  },
		{ "1",  "Use Qt debugger" },
	},
}

if not _OPTIONS["USE_QTDEBUG"] then
	if _OPTIONS["targetos"]=="windows" or _OPTIONS["targetos"]=="macosx" or _OPTIONS["targetos"]=="solaris" or _OPTIONS["targetos"]=="haiku" or _OPTIONS["targetos"] == "emscripten" or _OPTIONS["targetos"] == "os2" then
		_OPTIONS["USE_QTDEBUG"] = "0"
	else
		_OPTIONS["USE_QTDEBUG"] = "1"
	end
end