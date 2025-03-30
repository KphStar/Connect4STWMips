#/*********************************************************************

#*               SAN DIEGO STATE UNIVERISTY                           *

#*                   DUC M LE 132485155

#*              44 55 43 20 4D 49 4E 48 20 4C 45 0A

#*              31 33 32 34 38 35 31 35 35 0A                         *

#**********************************************************************

# Synchronous MIDI tone (original, sequential playback)
.macro play_midi_tone (%pitch, %duration, %instrument, %volume)
    li $v0, 33          # MIDI Out synchronous syscall
    li $a0, %pitch      # Pitch (0-127)
    li $a1, %duration   # Duration in milliseconds
    li $a2, %instrument # Instrument (0-127)
    li $a3, %volume     # Volume (0-127)
    syscall             # Plays tone and returns when complete
.end_macro

# Asynchronous MIDI tone (for simultaneous playback)
.macro play_midi_tone_async (%pitch, %duration, %instrument, %volume)
    li $v0, 31          # MIDI Out asynchronous syscall
    li $a0, %pitch      # Pitch (0-127)
    li $a1, %duration   # Duration in milliseconds
    li $a2, %instrument # Instrument (0-127)
    li $a3, %volume     # Volume (0-127)
    syscall             # Starts tone and returns immediately
.end_macro

# Original Super Mario Bros. victory tune (sequential)
.macro play_victory_tune
    # Super Mario Bros. flagpole victory tune: C4, G4, E5, C5, G4, C5
    play_midi_tone(60, 150, 80, 100)  # C4
    play_midi_tone(67, 150, 80, 100)  # G4
    play_midi_tone(76, 150, 80, 100)  # E5
    play_midi_tone(72, 150, 80, 100)  # C5
    play_midi_tone(67, 150, 80, 100)  # G4
    play_midi_tone(72, 150, 80, 100)  # C5
.end_macro

# New simultaneous victory chord (C major: C4, E4, G4)
.macro play_victory_chord
    # Plays C4, E4, G4 simultaneously as a victory chord
    play_midi_tone_async(60, 500, 80, 100)  # C4 (Middle C)
    play_midi_tone_async(64, 500, 80, 100)  # E4
    play_midi_tone_async(67, 500, 80, 100)  # G4
.end_macro