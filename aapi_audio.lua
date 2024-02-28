local aapi_audio = {}
function aapi_audio.rest(len,var)
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
            aapi_audio.playchord(speaker, "harp", array)
            aapi_audio.playchord(speaker, "bit", array)
            sleep(0.5)
            local array = { 9 }
            aapi_audio.playchord(speaker, "harp", array)
            aapi_audio.playchord(speaker, "bit", array)
            sleep(0.5)
            local array = { 14, 3 }
            aapi_audio.playchord(speaker, "harp", array)
            aapi_audio.playchord(speaker, "bit", array)
            sleep(0.4)
            local array = { 21 }
            aapi_audio.playchord(speaker, "harp", array)
            aapi_audio.playchord(speaker, "bit", array)
            sleep(0.3)
            local array = { 16, 10, 5 }
            aapi_audio.playchord(speaker, "harp", array)
            aapi_audio.playchord(speaker, "bit", array)
        end
        Soundlength = 1.7
    end
}
function aapi_audio.playchord(speaker, inst, array)
    for i = 1, #array do
        speaker.playNote(inst, 3, array[i])
    end
end
function aapi_audio.play(sound, speaker, count_)
    for i = 1, count_ do
        sounds[sound](speaker)
        sleep(Soundlength)
    end
end
function aapi_audio.newsound(name,chords,soundlength)
    local speakerarray = {}
    name = function()
        for i = 1, #speakerarray do
            local speaker = speakerarray[i]
            chords()
        end
        Soundlength = soundlength
    end
    table.insert(sounds,name())
end
function aapi_audio.mediaplay(audiofile, speakerarray)
    local dfpwm = require("cc.audio.dfpwm")
    --local speaker = speakerarray[1]
    local decoder = dfpwm.make_decoder()
    if speakerarray == nil then
        speakerarray = Speakers
    end
    for chunk in io.lines(audiofile, 16 * 1024) do
        for i = 1, #speakerarray, 1 do
            local buffer = decoder(chunk)

            while not speakerarray[i].playAudio(buffer, 3) do
                os.pullEvent("speaker_audio_empty")
            end
            speakerarray[i].playAudio(buffer, 3)
            -- while not speakerarray[i].playAudio(buffer) do
            --     os.pullEvent("speaker_audio_empty")
            -- end
        end
    end
end
function aapi_audio.playGameSound(sound,speaker,repet)
    local speakerarray = {}
    if type(speaker) == "string" then
        speakerarray = { speaker }
    else
        speakerarray = speaker
    end
    if repet == nil then
        repet = 1
    end
    for u = 1,repet do
        for i = 1, #speakerarray, 1 do
                speakerarray[i].playSound(sound)
        end
    end
end
function aapi_audio.gitsound(soundname, soundpath, speaker, keep)
    --local loader = require("aapi_loader")
    --loader.custom(soundpath, soundname, false)
    local git = require("gitapi")
    if Version == "m" then
        git.get("demandymcdonald", "Andy-API", "main", soundpath..soundname, "tmp/"..soundname)
    elseif Version == "d" then
        git.get("demandymcdonald", "Andy-API", "InDev", soundpath..soundname, "tmp/"..soundname)
    end

    aapi_audio.mediaplay("tmp/"..soundname, speaker)
    if keep == false then
        shell.run("delete /tmp/"..soundname)
    end
end
function aapi_audio.smcmd(command, soundname, soundpath, speaker)
    os.queueEvent("sm", { command, soundname, soundpath, speaker })
end
function aapi_audio.soundmanager()
    local sn = nil
    local sp = nil
    local speak = nil
    local commands = {
        medialoop = function()
            local function thread1()
                aapi_audio.gitsound(sn, sp, speak, true)
                while true do
                    aapi_audio.mediaplay(sp .. sn, speak)
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
                    aapi_audio.play(sn, speak, 1)
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
            aapi_audio.play(sn,speak,sp)
        end,
        playmedia = function()
            aapi_audio.gitsound(sn, sp, speak, false)
        end,
        playgamesound = function()
            aapi_audio.playGameSound(sn,speak,sp)
        end,
    }
    while true do
        local event, data = os.pullEvent("sm")
        local cmd = data[1]
        sp = data[3]
        sn = data[2]
        speak = data[4]
        commands[string.lower(cmd)]()
    end
end

return aapi_audio
