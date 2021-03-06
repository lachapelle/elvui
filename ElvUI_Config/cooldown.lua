local E, L, V, P, G = unpack(ElvUI)

local pairs = pairs

local function profile(db)
	return (db == "global" and E.db.cooldown) or E.db[db].cooldown
end

local function private(db)
	return (db == "global" and P.cooldown) or P[db].cooldown
end

local function group(order, db, label)
	E.Options.args.cooldown.args[db] = {
		order = order,
		type = "group",
		name = label,
		get = function(info)
			local t = (profile(db))[ info[#info] ]
			local d = (private(db))[ info[#info] ]
			return t.r, t.g, t.b, t.a, d.r, d.g, d.b
		end,
		set = function(info, r, g, b)
			local t = (profile(db))[ info[#info] ]
			t.r, t.g, t.b = r, g, b
			E:UpdateCooldownSettings(db)
		end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = label
			},
			reverse = {
				order = 2,
				type = "toggle",
				name = L["Reverse Toggle"],
				desc = L["Reverse Toggle will enable Cooldown Text on this module when the global setting is disabled and disable them when the global setting is enabled."],
				get = function(info) return (profile(db))[ info[#info] ] end,
				set = function(info, value) (profile(db))[ info[#info] ] = value E:UpdateCooldownSettings(db) end
			},
			secondsGroup = {
				order = 5,
				type = "group",
				name = L["Text Threshold"],
				guiInline = true,
				get = function(info) return (profile(db))[ info[#info] ] end,
				set = function(info, value) (profile(db))[ info[#info] ] = value E:UpdateCooldownSettings(db) end,
				disabled = function() return not (profile(db)).checkSeconds end,
				args = {
					checkSeconds = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						desc = L["This will override the global cooldown settings."],
						disabled = E.noop
					},
					mmssThreshold = {
						order = 2,
						type = "range",
						name = L["MM:SS Threshold"],
						desc = L["Threshold (in seconds) before text is shown in the MM:SS format. Set to -1 to never change to this format."],
						min = -1, max = 10800, step = 1
					},
					hhmmThreshold = {
						order = 3,
						type = "range",
						name = L["HH:MM Threshold"],
						desc = L["Threshold (in minutes) before text is shown in the HH:MM format. Set to -1 to never change to this format."],
						min = -1, max = 1440, step = 1
					}
				}
			},
			colorGroup = {
				order = 10,
				type = "group",
				name = L["Color Override"],
				guiInline = true,
				args = {
					override = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						desc = L["This will override the global cooldown settings."],
						get = function(info) return (profile(db))[ info[#info] ] end,
						set = function(info, value) (profile(db))[ info[#info] ] = value E:UpdateCooldownSettings(db) end,
					},
					threshold = {
						order = 2,
						type = "range",
						name = L["Low Threshold"],
						desc = L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"],
						min = -1, max = 20, step = 1,
						disabled = function() return not (profile(db)).override end,
						get = function(info) return (profile(db))[ info[#info] ] end,
						set = function(info, value) (profile(db))[ info[#info] ] = value E:UpdateCooldownSettings(db) end
					},
					spacer1 = {
						order = 3,
						type = "description",
						name = " "
					},
					spacer2 = {
						order = 4,
						type = "description",
						name = " "
					},
					expiringColor = {
						order = 5,
						type = "color",
						name = L["Expiring"],
						desc = L["Color when the text is about to expire"],
						disabled = function() return not (profile(db)).override end
					},
					secondsColor = {
						order = 6,
						type = "color",
						name = L["Seconds"],
						desc = L["Color when the text is in the seconds format."],
						disabled = function() return not (profile(db)).override end
					},
					minutesColor = {
						order = 7,
						type = "color",
						name = L["Minutes"],
						desc = L["Color when the text is in the minutes format."],
						disabled = function() return not (profile(db)).override end
					},
					hoursColor = {
						order = 8,
						type = "color",
						name = L["Hours"],
						desc = L["Color when the text is in the hours format."],
						disabled = function() return not (profile(db)).override end
					},
					daysColor = {
						order = 9,
						type = "color",
						name = L["Days"],
						desc = L["Color when the text is in the days format."],
						disabled = function() return not (profile(db)).override end
					},
					mmssColor = {
						order = 10,
						type = "color",
						name = L["MM:SS"],
						disabled = function() return not (profile(db)).override end
					},
					hhmmColor = {
						order = 11,
						type = "color",
						name = L["HH:MM"],
						disabled = function() return not (profile(db)).override end
					}
				}
			},
			fontGroup = {
				order = 20, -- keep this at the bottom
				type = "group",
				name = L["Fonts"],
				guiInline = true,
				get = function(info) return (profile(db)).fonts[ info[#info] ] end,
				set = function(info, value) (profile(db)).fonts[ info[#info] ] = value E:UpdateCooldownSettings(db) end,
				disabled = function() return not (profile(db)).fonts.enable end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						desc = L["This will override the global cooldown settings."],
						disabled = E.noop,
					},
					spacer1 = {
						order = 2,
						type = "description",
						name = " "
					},
					fontSize = {
						order = 3,
						type = "range",
						name = L["Font Size"],
						min = 10, max = 32, step = 1
					},
					font = {
						order = 4,
						type = "select",
						name = L["Font"],
						dialogControl = "LSM30_Font",
						values = AceGUIWidgetLSMlists.font,
					},
					fontOutline = {
						order = 5,
						type = "select",
						name = L["Font Outline"],
						values = {
							["NONE"] = L["None"],
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE"
						}
					}
				}
			}
		}
	}

	if db == "global" then
		-- clean up the main one
		E.Options.args.cooldown.args[db].args.reverse = nil
		E.Options.args.cooldown.args[db].args.colorGroup.args.override = nil

		-- remove disables
		for _, x in pairs(E.Options.args.cooldown.args[db].args.colorGroup.args) do
			if x.disabled then x.disabled = nil end
		end

		-- rename the tab
		E.Options.args.cooldown.args[db].args.colorGroup.name = L["Colors"]
	else
		E.Options.args.cooldown.args[db].args.colorGroup.args.spacer2 = nil
	end

	if db == "auras" then
		-- even though the top auras can support hiding the text don't allow this to be a setting to prevent confusion
		E.Options.args.cooldown.args[db].args.reverse = nil
		E.Options.args.cooldown.args[db].args.fontGroup = nil
	end

	if db == "nameplates" then
		E.Options.args.cooldown.args[db].args.fontGroup = nil
	end
end

E.Options.args.cooldown = {
	type = "group",
	name = L["Cooldown Text"],
	childGroups = "tab",
	get = function(info) return E.db.cooldown[ info[#info] ] end,
	set = function(info, value) E.db.cooldown[ info[#info] ] = value E:UpdateCooldownSettings("global") end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["COOLDOWN_DESC"],
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			desc = L["Display cooldown text on anything with the cooldown spiral."]
		}
	}
}

group(5,  "global",     L["Global"])
group(6,  "actionbar",  L["ActionBars"])
group(7,  "bags",       L["Bags"])
group(8,  "auras",      L["Auras"])
--group(9,  "nameplates", L["NamePlates"])
group(10, "unitframe",  L["UnitFrames"])