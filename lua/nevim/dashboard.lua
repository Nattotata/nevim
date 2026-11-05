-- Dashboard: random ASCII logo plus a few quick actions.
local logos = {
    {
        [[             |       :     . |]],
        [[             | '  :      '   |]],
        [[             |  .  | nevim | |]],
        [[   .--._ _...:.._ _.--. ,  ' |]],
        [[  (  ,  `        `  ,  )   . |]],
        [[   '-/              \-'  |   |]],
        [[     |  o   /\   o  |       :|]],
        [[     \     _\/_     / :  '   |]],
        [[     /'._   ^^   _.;___      |]],
        [[   /`    `""""""`      `\=   |]],
        [[ /`                     /=  .|]],
        [[;             '--,-----'=    |]],
        [[|                 `\  |    . |]],
        [[\                   \___ :   |]],
        [[/'.                     `\=  |]],
        [[\_/`--......_            /=  |]],
        [[            |`-.        /= : |]],
        [[            | : `-.__ /` .   |]],
        [[            |jgs .   ` |    '|]],
        [[            |  .  : `   . |  |]],
    },
    {
        [[\|/    \|/]],
        [[  \    /]],
        [[   \_/  ___   ___]],
        [[   o o-'   '''   ']],
        [[    O -.         |\]],
        [[        | |'''| |]],
        [[  nevim  ||   | |]],
        [[         ||    ||]],
        [[         "     "]],
    },
    {
        [[  _      _]],
        [[ : `.--.' ;              _....,_]],
        [[ .'      `.      _..--'"'       `-._]],
        [[:          :_.-'"                  .`.]],
        [[:  6    6  :                     :  '.;]],
        [[:          :    nevim             `..';]],
        [[`: .----. :'                          ;]],
        [[  `._Y _.'               '           ;]],
        [[    'U'      .'          `.         ;]],
        [[       `:   ;`-..___       `.     .'`.]],
        [[jgs    _:   :  :    ```"''"'``.    `.  `.]],
        [[     .'     ;..'            .'       `.'`]],
        [[    `.......'              `........-'`]],
    },
    {
        [[              ____...---...___]],
        [[___.....---"""        .       ""--..____]],
        [[     .                  .            .]],
        [[ . nevim       _.--._       /|]],
        [[        .    .'()..()`.    / /]],
        [[            ( `-.__.-' )  ( (    .]],
        [[   .         \        /    \ \]],
        [[       .      \      /      ) )        .]],
        [[            .' -.__.- `.-.-'_.']],
        [[ .        .'  /-____-\  `.-'       .]],
        [[          \  /-.____.-\  /-.]],
        [[           \ \`-.__.-'/ /\|\|           .]],
        [[          .'  `.    .'  `.]],
        [[          |/\/\|    |/\/\|]],
        [[jro]],
    },
    {
        [[                 /eeeeeeeeeee\     nevim   ]],
        [[   /RRRRRRRRRR\ /eeeeeeeeeeeee\ /RRRRRRRRRR\ ]],
        [[  /RRRRRRRRRRRR\|eeeeeeeeeeeee|/RRRRRRRRRRRR\ ]],
        [[ /RRRRRRRRRRRRRR +++++++++++++ RRRRRRRRRRRRRR\ ]],
        [[|RRRRRRRRRRRRRR ############### RRRRRRRRRRRRRR| ]],
        [[|RRRRRRRRRRRRR ######### ####### RRRRRRRRRRRRR| ]],
        [[ \RRRRRRRRRRR ######### ######### RRRRRRRRRR/ ]],
        [[   |RRRRRRRRR ########## ######## RRRRRRRR| ]],
        [[  |RRRRRRRRRR ################### RRRRRRRRR| ]],
        [[               ######     ###### ]],
        [[               #####       ##### ]],
        [[               #nnn#       #nnn# ]],
    },
}

math.randomseed(os.clock() * 1000000)
local picked_logo = logos[math.random(#logos)]

local ok_alpha, alpha = pcall(require, "alpha")
if ok_alpha then
    local dashboard = require("alpha.themes.dashboard")
    local variant = os.getenv("NEVIM_VARIANT") or "desktop"
    local color_variant = variant == "pi" and " [ RASPBERRY PI ] " or " [ DESKTOP ] "
    table.insert(picked_logo, "")
    table.insert(picked_logo, "      " .. color_variant)
    dashboard.section.header.val = picked_logo
    dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":FzfLua files<CR>"),
        dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("g", "  LazyGit", ":LazyGit<CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
    }
    alpha.setup(dashboard.opts)
end
