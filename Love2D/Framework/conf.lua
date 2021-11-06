function love.conf(t)
    t.identity = "SparFramework"
    t.appendidentity = true
    t.externalstorage = true
    t.gammacorrect = true
    t.window.title = "SparFramework"
    t.window.width = 1920
    t.window.height = 1080
    -- t.window.width = 500
    -- t.window.height = 500
    t.window.resizable = true
    t.window.minwidth = 100
    t.window.minheight = 100
    -- t.window.fullscreen = true
    t.window.msaa = 0
    t.window.depth = 0
    t.window.stencil = 8
    t.window.highdpi = true
    t.window.vsync = 0
    t.modules.joystick = false
end

