Import-Module -Name Spotishell



New-SpotifyApplication -Name "spo" -ClientId "10d30621aa8745b986b498752f608d2f" -ClientSecret "8f7dd22187d5438b823949fca0d8f05e" -RedirectUri "https://kichonvebin/callback/"
Start-Playback -ApplicationName "spo" -ContextUri "spotify:album:5ht7ItJgpBH7W6vJ5BqpPr" -OffsetPosition 5 -PositionMs 0


