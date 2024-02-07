local aapi_sound = {}
local sounds = {
    welcomesong = function(speakerarray)
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
function aapi_sound.mediaplay(audiofile,speakerarray)
    local dfpwm = require("cc.audio.dfpwm")
    local speaker = speakerarray[1]
    local decoder = dfpwm.make_decoder()
    for chunk in io.lines(audiofile, 16 * 1024) do
        buffer = decoder(chunk)

        while not speaker.playAudio(buffer,3) do
            os.pullEvent("speaker_audio_empty")
        end
    end
    for i=1,#speakerarray,1 do
        speakerarray[i].playAudio(buffer, 3)
        while not speaker.playAudio(buffer) do
            os.pullEvent("speaker_audio_empty")
        end
    end
end
return aapi_sound
