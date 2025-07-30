Output demo2.webp
Set Shell zsh
Set FontSize 18
Set Width 1280
Set Height 720
Set Framerate 60
Set Padding 10
Set FontFamily "notonoto"
Set WindowBar Colorful
Set BorderRadius 10
Set Margin 20
Set MarginFill "#674EFF"
Set CursorBlink false

Type "nvim_demo test2.md"
Enter
Sleep 2s

Type@400ms "yf,"
Sleep 1s
Type "j"
Sleep 0.5s
Type "p"
Sleep 2s
Ctrl+G
Type "kd"
Sleep 0.5s
Type "k"
Sleep 0.5s
Type "^"
Sleep 0.5s

Ctrl+G
Type "ke"
Sleep 0.5s
Type@400ms "df."
Sleep 1s
Ctrl+G
Type "kd"
Sleep 0.5s
Type "^"
Sleep 0.5s
Ctrl+G
Type "ke"
Sleep 0.5s
Type@400ms "d2f,"
Sleep 1s
Ctrl+G
Type "kd"
Sleep 0.5s
Type "2j^"
Sleep 0.5s

Ctrl+G
Type "ke"
Sleep 0.5s
Type@400ms "cf,"
Sleep 1s
Type "lorem ipusum ... "
Sleep 0.5s
Ctrl+[
Sleep 0.5s
Ctrl+G
Type "kd"
Sleep 1s

Type ":q!"
Enter
Sleep 2s
