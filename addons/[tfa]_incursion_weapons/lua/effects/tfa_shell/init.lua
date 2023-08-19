
-- Copyright (c) 2018 TFA Base Devs

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE


EFFECT.ShellPresets = {
	["sniper"] = {"models/hdweapons/rifleshell.mdl", math.pow(0.487 / 1.236636, 1 / 3), 90}, --1.236636 is shell diameter, then divide base diameter into that for 7.62x54mm
	["rifle"] = {"models/hdweapons/rifleshell.mdl", math.pow(0.4709 / 1.236636, 1 / 3), 90}, --1.236636 is shell diameter, then divide base diameter into that for standard nato rifle
	["pistol"] = {"models/hdweapons/shell.mdl", math.pow(0.391 / 0.955581, 1 / 3), 90}, --0.955581 is shell diameter, then divide base diameter into that for 9mm luger
	["smg"] = {"models/hdweapons/shell.mdl", math.pow(.476 / 0.955581, 1 / 3), 90}, --.45 acp
	["shotgun"] = {"models/hdweapons/shotgun_shell.mdl", 1, 90}
}

function EFFECT:ComputeSmokeLighting()
end

function EFFECT:Init(data)
end

function EFFECT:Render()
end