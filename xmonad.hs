-- IMPORTS

import XMonad
import Data.Monoid
import System.Exit
import Graphics.X11.ExtraTypes.XF86
import XMonad.Util.SpawnOnce
import XMonad.Util.Run
import XMonad.Hooks.ManageDocks
import XMonad.Layout.NoBorders
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Actions.CycleWS
import XMonad.Actions.PhysicalScreens
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.Spacing
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.FixedAspectRatio
import XMonad.Util.Hacks
import Data.Maybe (listToMaybe)

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

focusAndViewOtherScreen :: X ()
focusAndViewOtherScreen = do
  ws <- gets windowset
  let visibles = W.visible ws
  case visibles of
    (other:_) -> do
      let targetWorkspace = W.tag $ W.workspace other
      windows $ W.greedyView targetWorkspace  -- aquí la magia
    _ -> pure ()

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal :: [Char]
myTerminal = "alacritty"

myEmacs :: [Char]
myEmacs = "emacsclient -c -a 'emacs' "

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth :: Dimension
myBorderWidth = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask :: KeyMask
myModMask = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces :: [[Char]]
myWorkspaces = ["1","2","3","4","5","6","7","8","9"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor :: [Char]
myNormalBorderColor = "#282a36"
myFocusedBorderColor :: [Char]
myFocusedBorderColor = "#8be9fd"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys =
  -- launch terminal
    [("M-<Return>",  spawn myTerminal)
    -- launch dmenu
    , ("M-p", spawn "rofi -show run")
    -- launch firefox
    , ("M-w", spawn "firefox")
    -- launch slock
    , ("M-S-l", spawn "slock")
    -- launch emacs
    -- , ("M-e", spawn (myEmacs))
    -- launch vscode
    , ("M-o", spawn "code")
    -- launch file manager
    , ("M-f", spawn "nautilus")
    -- Volume/Media
    , ("<XF86AudioLowerVolume>", spawn "amixer -q sset Master 5%-")
    , ("M1-<Down>", spawn "amixer -q sset Master 5%-")
    , ("<XF86AudioRaiseVolume>", spawn "amixer -q sset Master 5%+")
    , ("M1-<Up>", spawn "amixer -q sset Master 5%+")
    , ("<XF86AudioMute>", spawn "amixer set Master toggle")
    , ("M1-m", spawn "amixer set Master toggle")
    , ("<XF86AudioPlay>", spawn "playerctl play-pause")
    , ("M1-p", spawn "playerctl play-pause")
    , ("<XF86AudioNext>", spawn "playerctl next")
    , ("M1-<Right>", spawn "playerctl next")
    , ("<XF86AudioPrev>", spawn "playerctl previous")
    , ("M1-<Left>", spawn "playerctl previous")
    , ("<XF86MonBrightnessUp>", spawn "light -A 10")
    , ("<XF86MonBrightnessDown>", spawn "light -U 10")
    -- launch gmrun
    , ("M-S-p", spawn "gmrun")
    -- close focused window
    , ("M-q", kill)
     -- Rotate through the available layout algorithms
    , ("M-<Space>", sendMessage NextLayout)
    --  Reset the layouts on the current workspace to default
    -- , ("M-S-<Space>", setLayout $ XMonad.layoutHook myLayout)
    -- Resize viewed windows to the correct size
    , ("M-g", withFocused $ sendMessage . ResetRatio)
    -- Toggle notifications
    , ("M-S-n", spawn "dunstctl set-paused toggle")
    -- Move focus to the next window
    , ("M-<Tab>", windows W.focusDown)
    -- Move focus to the next window
    , ("M1-<Tab>", windows W.focusDown)
    -- Move focus to the next window
    , ("M-j", windows W.focusDown)
    -- Move focus to the previous window
    , ("M-k", windows W.focusUp  )
    -- Move to last workspace
    , ("M-a", toggleWS)
    -- Move to last workspace
    , ("M-n", focusAndViewOtherScreen)
    -- Increase number of windows in the master area
    , ("M-u", sendMessage (IncMasterN 1))
    -- Decrease number of windows in the master area
    , ("M-i", sendMessage (IncMasterN (-1)))
    -- Move focus to the previous window
    , ("M-S-<Tab>", windows W.focusUp  )
    -- Move focus to the master window
    , ("M-m", windows W.focusMaster  )
    -- Swap the focused window and the master window
    , ("M-S-<Return>", windows W.swapMaster)
    -- Swap the focused window with the next window
    , ("M-S-j", windows W.swapDown  )
    -- Swap the focused window with the previous window
    , ("M-S-k", windows W.swapUp    )
    -- Shrink the master area
    , ("M-h", sendMessage Shrink)
    -- Expand the master area
    , ("M-l", sendMessage Expand)
    -- Push window back into tiling
    , ("M-t", withFocused $ windows . W.sink)
    -- Increment the number of windows in the master area
    , ("M-]", sendMessage (IncMasterN 1))
    -- Deincrement the number of windows in the master area
    , ("M-[", sendMessage (IncMasterN (-1)))
    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    , ("M-b", sendMessage ToggleStruts)
    -- Quit xmonad
    , ("M-S-q", io (exitWith ExitSuccess))
    -- Restart xmonad
    , ("M-c", spawn "pkill polybar; xmonad --recompile; xmonad --restart")
    -- Switch focus to next monitor
    , ("M-.", nextScreen)
    -- Swi tch focus to prev monitor
    , ("M-,", prevScreen)
    -- Swi tch focus to prev monitor
    , ("M-S-,", shiftPrevScreen)
    -- Switch focus to next monitor
    , ("M-S-.", shiftNextScreen)
    -- Redshift
    , ("M-r", spawn "redshift -O 2400")
    , ("M-S-r", spawn "redshift -x")
    -- Scrot
    , ("M-s", spawn "scrot '/tmp/%F_%T_$wx$h.png' -e 'xclip -selection clipboard -target image/png -i $f'")
    , ("M-S-s", spawn "scrot -s '/tmp/%F_%T_$wx$h.png' -e 'xclip -selection clipboard -target image/png -i $f'")
    -- Emacsclient
    , ("M-e e", spawn (myEmacs))
    -- Emacslient EMMS (music)
    , ("M-e a", spawn (myEmacs ++ ("--eval '(emms)' --eval '(emms-play-directory-tree \"~/Music/\")'")))
    -- Emacslient Ibuffer
    , ("M-e b", spawn (myEmacs ++ ("--eval '(ibuffer)'")))
    -- Emacslient Dired
    , ("M-e d", spawn (myEmacs ++ ("--eval '(dired \"~\")'")))
    -- Emacslient ERC (IRC)
    , ("M-e i", spawn (myEmacs ++ ("--eval '(erc)'")))
    -- Emacslient Elfeed (RSS)
    , ("M-e n", spawn (myEmacs ++ ("--eval '(elfeed)'")))
    -- Emacslient Eshell
    , ("M-e s", spawn (myEmacs ++ ("--eval '(eshell)'")))
    -- Emacslient Vterm
    , ("M-e v", spawn (myEmacs ++ ("--eval '(+vterm/here nil)'")))
    -- Emacslient EWW Browser
    , ("M-e w", spawn (myEmacs ++ ("--eval '(doom/window-maximize-buffer(eww \"google.com\"))'")))
    -- Emacslient open work files
    , ("M-e k", spawn (myEmacs ++ ("--eval '(dired \"~/EKUPD\")'")))
    -- Emacslient select project
    , ("M-e j", spawn (myEmacs ++ ("--eval '(projectile-dired)'")))
    -- Emacslient select project recent files
    , ("M-e l", spawn (myEmacs ++ ("--eval '(projectile-switch-project)'")))
    -- Emacslient open XMonad config file
    , ("M-x", spawn (myEmacs ++ ("~/.xmonad/xmonad.hs")))
    ]
    ++
    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [ (otherModMasks ++ "M-" ++ key, action tag)
        | (tag, key)  <- zip myWorkspaces (map (\x -> "<F" ++ show x ++ ">") [1..9])
        , (otherModMasks, action) <- [ ("", windows . W.greedyView) -- or W.view
                                     , ("S-", windows . W.shift)]
    ]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = avoidStruts $
  smartSpacing 1 $
  (smartBorders tiled  ||| noBorders Full)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   =  Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = manageDocks <+> composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "confirm"         --> doFloat
    , className =? "file_progress"   --> doFloat
    , className =? "dialog"          --> doFloat
    , className =? "download"        --> doFloat
    , className =? "error"           --> doFloat
    , className =? "Gimp"            --> doFloat
    , className =? "notification"    --> doFloat
    , className =? "pinentry-gtk-2"  --> doFloat
    , className =? "splash"          --> doFloat
    , className =? "toolbar"         --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
    , isFullscreen -->  doFullFloat
    , resource  =? "kdesktop"       --> doIgnore ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
-- myLogHook = return ()
myLogHook = dynamicLog

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  spawn "feh --randomize --bg-fill ~/Pictures/Wallpapers/*"
  spawnOnce "picom &"
  spawnOnce "xsetroot -cursor_name left_ptr &"
  spawn "/usr/bin/emacs --daemon &"
  spawnOnce "unclutter -idle 1 -root &"
  spawn "nm-applet &"
  spawn "polybar -c ~/.config/polybar/config.ini"
  spawn "setxkbmap -layout us -variant altgr-intl &"
  spawnOnce "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &"
  spawnOnce "/usr/libexec/polkit-gnome-authentication-agent-1 &"
  -- Enable tap to click on touchpad
  spawnOnce "xinput set-prop 11 330 1"
  spawnOnce "systemctl --user start docker-desktop"
  spawnOnce "xrandr --output eDP-1 --mode 1920x1080 --pos 1920x228 --rotate normal --output HDMI-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal"

  setWMName "LG3D"


------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
  xmonad $ docks $ ewmh def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        -- keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = windowedFullscreenFixEventHook <> trayerPaddingXmobarEventHook <> myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    } `additionalKeysP` myKeys
