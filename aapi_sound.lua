local aapi_sound = {}
function aapi_sound.rest(len,var)
    sleep(len)
    var = var + len
    return var
end
local sounds = {
    welcomesong = function(speakerarray)
        local length = 0
        for i = 1, #speakerarray do
            local speaker = speakerarray[i]
            local array = { 0, 16 }
            aapi_sound.playchord(speaker, "harp", array)
            aapi_sound.playchord(speaker, "bit", array)
            sleep(0.5)
            local array = { 9 }
            aapi_sound.playchord(speaker, "harp", array)
            aapi_sound.playchord(speaker, "bit", array)
            sleep(0.5)
            local array = { 14, 3 }
            aapi_sound.playchord(speaker, "harp", array)
            aapi_sound.playchord(speaker, "bit", array)
            sleep(0.4)
            local array = { 21 }
            aapi_sound.playchord(speaker, "harp", array)
            aapi_sound.playchord(speaker, "bit", array)
            sleep(0.3)
            local array = { 16, 10, 5 }
            aapi_sound.playchord(speaker, "harp", array)
            aapi_sound.playchord(speaker, "bit", array)
        end
        Soundlength = 1.7
    end
}
function aapi_sound.playchord(speaker, inst, array)
    for i = 1, #array do
        speaker.playNote(inst, 3, array[i])
    end
end
function aapi_sound.play(sound, speaker, count_)
    for i = 1, count_ do
        sounds[sound](speaker)
        sleep(Soundlength)
    end
end
function aapi_sound.newsound(name,chords,soundlength)
    name = function()
        for i = 1, #speakerarray do
            local speaker = speakerarray[i]
            chords()
        end
        Soundlength = soundlength
    end
    table.insert(sounds,name())
end
function aapi_sound.mediaplay(audiofile, speakerarray)
    local dfpwm = require("cc.audio.dfpwm")
    local speaker = speakerarray[1]
    local decoder = dfpwm.make_decoder()
    for chunk in io.lines(audiofile, 16 * 1024) do
        buffer = decoder(chunk)

        while not speaker.playAudio(buffer, 3) do
            os.pullEvent("speaker_audio_empty")
        end
    end
    for i = 1, #speakerarray, 1 do
        speakerarray[i].playAudio(buffer, 3)
        while not speaker.playAudio(buffer) do
            os.pullEvent("speaker_audio_empty")
        end
    end
end
function aapi_sound.gitsound(soundname, soundpath, speaker, keep)
    local loader = require("aapi_loader")
    loader.custom(soundpath, soundname, false)
    aapi_sound.mediaplay(soundpath .. soundname, speaker)
    if keep == false then
        shell.run("delete " .. soundpath .. soundname)
    end
end
function aapi_sound.sound(command, soundname,soundpath, speaker)
    os.queueEvent("sm",{command,soundname,soundpath,speaker})    
end
function aapi_sound.soundmanager()
    local sn = nil
    local sp = nil
    local speak = nil
    local commands = {
        medialoop = function()
            local function thread1()
                aapi_sound.gitsound(sn, sp, speak, true)
                while true do
                    aapi_sound.mediaplay(sp .. sn, speak)
                end
            end
            local function thread2()
                local event, data = os.pullEvent("sm")
                if data[1] == "stoploop" then
                    return
                else
                    thread2()
                end 
            end
            parallel.waitForAny(thread1,thread2)
        end,
        soundloop = function()
            local function thread1()
                while true do
                    aapi_sound.play(sn, speak, 1)
                end
            end
            local function thread2()
                local event, data = os.pullEvent("sm")
                if data[1] == "stoploop" then
                    return
                else
                    thread2()
                end 
            end
            parallel.waitForAny(thread1,thread2)
        end,
        playsound = function()
            aapi_sound.play(sn,speak,sp)
        end,
        playmedia = function()
            aapi_sound.gitsound(sn, sp, speak, false)
        end,

    }
    while true do 
        local event, data = os.pullEvent("sm")
        local cmd = data[1]
        local sp = data[3]
        local sn = data[2]
        local speak = data[4]
        commands[cmd]()
    end
end

return aapi_sound
