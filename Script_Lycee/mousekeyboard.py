import keyboard,mouse,time,winreg, VarSitePourMouseKeyboard
connect_to_reg = winreg.OpenKey(winreg.HKEY_CURRENT_USER,r"SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice")
browser = winreg.EnumValue(connect_to_reg, 0)
browser = browser[1] #Valeur clé de registre
if browser == "MSEdgeHTM": browser = "edge"
elif browser == "ChromeHTML": browser = "chrome"
elif browser == "Opera GXStable": browser = "opera"
else : browser = "edge"

mouse.move(196,1064,duration=0.5)
mouse.click(button="left")
for i in range(len(browser)):
    time.sleep(0.05)
    keyboard.write(browser[i], delay=0.1)
keyboard.press("enter")
time.sleep(1)
keyboard.press_and_release("win + up")
mouse.move(274,50,duration=0.5)
time.sleep(0.1)
mouse.click(button="left")
l = VarSitePourMouseKeyboard.site
if len(l) <= 15: v=0.09
elif len(l) <= 35: v=0.07
elif len(l) > 35: v=0.04
for i in range(len(l)):
    keyboard.write(l[i],delay=v)
keyboard.press("enter")



