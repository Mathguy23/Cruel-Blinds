--- STEAMODDED HEADER
--- MOD_NAME: Cruel Blinds
--- MOD_ID: CBL
--- PREFIX: cruel
--- MOD_AUTHOR: [mathguy]
--- MOD_DESCRIPTION: Cruel Blinds
--- VERSION: 1.2.0
----------------------------------------------
------------MOD CODE -------------------------

SMODS.Atlas({ key = "blinds", atlas_table = "ANIMATION_ATLAS", path = "blinds.png", px = 34, py = 34, frames = 21 })

SMODS.Atlas({ key = "broken", atlas_table = "ASSET_ATLAS", path = "broken.png", px = 71, py = 95,
    inject = function(self)
        local file_path = type(self.path) == 'table' and
            (self.path[G.SETTINGS.language] or self.path['default'] or self.path['en-us']) or self.path
        if file_path == 'DEFAULT' then return end
        -- language specific sprites override fully defined sprites only if that language is set
        if self.language and not (G.SETTINGS.language == self.language) then return end
        if not self.language and self.obj_table[('%s_%s'):format(self.key, G.SETTINGS.language)] then return end
        self.full_path = (self.mod and self.mod.path or SMODS.path) ..
            'assets/' .. G.SETTINGS.GRAPHICS.texture_scaling .. 'x/' .. file_path
        local file_data = assert(NFS.newFileData(self.full_path),
            ('Failed to collect file data for Atlas %s'):format(self.key))
        self.image_data = assert(love.image.newImageData(file_data),
            ('Failed to initialize image data for Atlas %s'):format(self.key))
        self.image = love.graphics.newImage(self.image_data,
            { mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling })
        G[self.atlas_table][self.key_noloc or self.key] = self
        G.shared_seals['Broken'] = Sprite(0, 0, G.CARD_W, G.CARD_H, G[self.atlas_table][self.key_noloc or self.key], {x = 0,y = 0})
    end
})

SMODS.Atlas({ key = "decks", atlas_table = "ASSET_ATLAS", path = "Backs.png", px = 71, py = 95})

SMODS.Blind	{
    loc_txt = {
        name = 'The Mind',
        text = { 'Only one card', 'face up' }
    },
    key = 'mind',
    config = {},
    boss = {min = 2, max = 10, hardcore = true}, 
    boss_colour = HEX("777777"),
    atlas = "blinds",
    pos = { x = 0, y = 0},
    vars = {},
    dollars = 5,
    mult = 2, 
    drawn_to_hand = function(self)
        local any_flipped = nil
        for k, v in ipairs(G.hand.cards) do
            if v.facing == 'front' then
                any_flipped = true
            end
        end
        if not any_flipped then 
            local forced_card = pseudorandom_element(G.hand.cards, pseudoseed('mind_blind'))
            forced_card:flip()
        end

    end,
    stay_flipped = function(self, area, card)
        if area == G.hand then
            return true
        end
    end,
    disable = function(self)
        for i = 1, #G.hand.cards do
            if G.hand.cards[i].facing == 'back' then
                G.hand.cards[i]:flip()
            end
        end
        for k, v in pairs(G.playing_cards) do
            v.ability.wheel_flipped = nil
        end
    end
}

SMODS.Blind	{
    loc_txt = {
        name = 'The Jaw',
        text = { 'Drawing cards costs', '$1 each' }
    },
    key = 'jaw',
    name = 'The Jaw',
    config = {},
    boss = {min = 4, max = 10, hardcore = true}, 
    boss_colour = HEX("777777"),
    atlas = "blinds",
    pos = { x = 0, y = 1},
    vars = {},
    dollars = 7,
    mult = 2,
}

SMODS.Blind	{
    loc_txt = {
        name = 'The Steal',
        text = { '#1# isn\'t a', 'poker hand' }
    },
    key = 'steal',
    name = 'The Steal',
    config = {},
    boss = {min = 3, max = 10, hardcore = true}, 
    boss_colour = HEX("2222BB"),
    atlas = "blinds",
    pos = { x = 0, y = 2},
    vars = {"(most played hand)"},
    dollars = 5,
    mult = 2,
    loc_vars = function(self)
        result = {localize(G.GAME.current_round.most_played_poker_hand, 'poker_hands')}
        -- if G.GAME.current_round.most_played_poker_hand == "High Card" then
        --     result = {localize("Pair", 'poker_hands')}
        -- end
        return {vars = result}
    end,
    debuff_hand = function(self, cards, hand, handname, check)
        if (G.GAME.current_round.most_played_poker_hand == 'High Card') and (handname == "High Card") and not G.GAME.blind.disabled then
            return true
        end
        return false
    end,
    get_loc_debuff_text = function(self)
        return "You must play a poker hand."
    end
}

SMODS.Blind	{
    loc_txt = {
        name = 'The Sink',
        text = { 'No hands allowed until', 'a Flush is discarded' }
    },
    key = 'sink',
    name = 'The Sink',
    config = {},
    boss = {min = 1, max = 10, hardcore = true}, 
    boss_colour = HEX("CCCCFF"),
    atlas = "blinds",
    pos = { x = 0, y = 3},
    vars = {},
    dollars = 5,
    mult = 2,
    debuff_hand = function(self, cards, hand, handname, check)
        G.GAME.blind.triggered = true
        return true
    end
}

SMODS.Blind	{
    loc_txt = {
        name = 'The Day',
        text = { 'Spades and Clubs are debuffed', 'and drawn face down' }
    },
    key = 'day',
    config = {},
    boss = {min = 1, max = 10, hardcore = true}, 
    boss_colour = HEX("EEEE88"),
    atlas = "blinds",
    pos = { x = 0, y = 4},
    vars = {},
    dollars = 5,
    mult = 2,
    stay_flipped = function(self, area, card)
        if area == G.hand and (card:is_suit("Clubs", true) or card:is_suit("Spades", true)) and not G.GAME.blind.disabled then
            return true
        end
    end,
    debuff_card = function(self, card, from_blind)
        if (card.area ~= G.jokers) and (card:is_suit("Clubs", true) or card:is_suit("Spades", true)) and not G.GAME.blind.disabled then
            return true
        end
        return false
    end,
    disable = function(self)
        for i = 1, #G.hand.cards do
            if G.hand.cards[i].facing == 'back' then
                G.hand.cards[i]:flip()
            end
        end
        for k, v in pairs(G.playing_cards) do
            v.ability.wheel_flipped = nil
        end
    end
}

SMODS.Blind	{
    loc_txt = {
        name = 'The Night',
        text = { 'Hearts and Diamonds are debuffed', 'and drawn face down' }
    },
    key = 'night',
    config = {},
    boss = {min = 1, max = 10, hardcore = true}, 
    boss_colour = HEX("8888EE"),
    atlas = "blinds",
    pos = { x = 0, y = 5},
    vars = {},
    dollars = 5,
    mult = 2,
    stay_flipped = function(self, area, card)
        if area == G.hand and (card:is_suit("Hearts", true) or card:is_suit("Diamonds", true)) and not G.GAME.blind.disabled then
            return true
        end
    end,
    debuff_card = function(self, card, from_blind)
        if (card.area ~= G.jokers) and (card:is_suit("Hearts", true) or card:is_suit("Diamonds", true)) and not G.GAME.blind.disabled then
            return true
        end
        return false
    end,
    disable = function(self)
        for i = 1, #G.hand.cards do
            if G.hand.cards[i].facing == 'back' then
                G.hand.cards[i]:flip()
            end
        end
        for k, v in pairs(G.playing_cards) do
            v.ability.wheel_flipped = nil
        end
    end
}

SMODS.Blind	{
    loc_txt = {
        name = 'The Tide',
        text = { 'Start with 0 discards', '-1 Hands' }
    },
    key = 'tide',
    config = {},
    boss = {min = 2, max = 10, hardcore = true}, 
    boss_colour = HEX("AAAACC"),
    atlas = "blinds",
    pos = { x = 0, y = 6},
    vars = {},
    dollars = 5,
    mult = 2,
    set_blind = function(self, reset, silent)
        if not reset then
            if (G.GAME.current_round.discards_left > 0) then
                G.GAME.blind.discards_sub = G.GAME.current_round.discards_left
                ease_discard(-G.GAME.blind.discards_sub)
            end
            if (G.GAME.round_resets.hands > 1) then
                G.GAME.blind.hands_sub = 1
                ease_hands_played(-G.GAME.blind.hands_sub)
            end
        end
    end,
    disable = function(self)
        ease_discard(G.GAME.blind.discards_sub or 0)
        ease_hands_played(G.GAME.blind.hands_sub or 0)
    end
}

SMODS.Blind	{
    loc_txt = {
        name = 'The Sword',
        text = { 'Play only 1 hand.', '-1 Discards' }
    },
    key = 'sword',
    config = {},
    boss = {min = 2, max = 10, hardcore = true}, 
    boss_colour = HEX("116611"),
    atlas = "blinds",
    pos = { x = 0, y = 7},
    vars = {},
    dollars = 5,
    mult = 1,
    set_blind = function(self, reset, silent)
        if not reset then
            if (G.GAME.round_resets.hands > 1) then
                G.GAME.blind.hands_sub = G.GAME.round_resets.hands - 1
                ease_hands_played(-G.GAME.blind.hands_sub)
            end
            if (G.GAME.current_round.discards_left > 0) then
                G.GAME.blind.discards_sub = 1
                ease_discard(-G.GAME.blind.discards_sub)
            end
        end
    end,
    disable = function(self)
        ease_discard(G.GAME.blind.discards_sub or 0)
        ease_hands_played(G.GAME.blind.hands_sub or 0)
    end
}

SMODS.Blind	{
    loc_txt = {
        name = 'The Shackle',
        text = { '-2 Hand Size' }
    },
    key = 'shackle',
    config = {},
    boss = {min = 4, max = 10, hardcore = true}, 
    boss_colour = HEX("444444"),
    atlas = "blinds",
    pos = { x = 0, y = 8},
    vars = {},
    dollars = 5,
    mult = 2,
    defeat = function(self)
        if not G.GAME.blind.disabled then
            G.hand:change_size(2)
        end
    end,
    set_blind = function(self, reset, silent)
        if not reset then
            G.hand:change_size(-2)
        end
    end,
    disable = function(self)
        G.hand:change_size(2)
        
        G.FUNCS.draw_from_deck_to_hand(2)
    end
}

SMODS.Blind	{
    loc_txt = {
        name = 'The Hurdle',
        text = { '+1 Ante permanently' }
    },
    key = 'hurdle',
    config = {},
    boss = {min = 2, max = 10, hardcore = true}, 
    boss_colour = HEX("EEBB22"),
    atlas = "blinds",
    pos = { x = 0, y = 9},
    vars = {},
    dollars = 5,
    mult = 2,
    set_blind = function(self, reset, silent)
        if not reset then
            ease_ante(1)
            G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
            G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante+1
            G.GAME.blind.chips = get_blind_amount(G.GAME.round_resets.ante+1)*G.GAME.blind.mult*G.GAME.starting_params.ante_scaling
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            G.GAME.blind:set_text()
        end
    end,
    disable = function(self)
        ease_ante(-1)
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante-1
        G.GAME.blind.chips = get_blind_amount(G.GAME.round_resets.ante-1)*G.GAME.blind.mult*G.GAME.starting_params.ante_scaling
        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
        G.GAME.blind:set_text()
    end
}

SMODS.Blind	{
    loc_txt = {
        name = 'The Collapse',
        text = { '+4% blind size each hand', 'per time poker hand played' }
    },
    key = 'collapse',
    config = {},
    boss = {min = 4, max = 10, hardcore = true}, 
    boss_colour = HEX("443388"),
    atlas = "blinds",
    pos = { x = 0, y = 10},
    vars = {},
    dollars = 5,
    mult = 2,
    disable = function(self)
        G.GAME.blind.chips = get_blind_amount(G.GAME.round_resets.ante)*G.GAME.blind.mult*G.GAME.starting_params.ante_scaling
        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
        G.GAME.blind:set_text()
    end,
    debuff_hand = function(self, cards, hand, handname, check)
        G.GAME.blind.triggered = false
        if not check then
            G.GAME.blind.triggered = true
            local count = G.GAME.hands[handname].played - 1
            if (count > 0) then
                G.GAME.blind.chips = math.floor(G.GAME.blind.chips * (1 + (0.04 * count)))
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                G.GAME.blind:set_text()
                G.hand_text_area.blind_chips:juice_up()
            end
        end
    end
}

SMODS.Blind	{
    loc_txt = {
        name = 'The Reach',
        text = { 'Disperse half of levels of played', 'poker hand amongst other poker hands' }
    },
    key = 'reach',
    config = {},
    boss = {min = 4, max = 10, hardcore = true}, 
    boss_colour = HEX("881188"),
    atlas = "blinds",
    pos = { x = 0, y = 11},
    vars = {},
    dollars = 5,
    mult = 2,
    debuff_hand = function(self, cards, hand, handname, check)
        G.GAME.blind.triggered = false
        if not check then
            local count = math.min(G.GAME.hands[handname].level - 1, math.floor(G.GAME.hands[handname].level / 2))
            if (count > 0) then
                if not check then
                    G.GAME.blind.triggered = true
                    level_up_hand(G.GAME.blind.children.animatedSprite, handname, nil, -count)
                    G.GAME.blind:wiggle()
                    local disperse_table = {}
                    local options = {}
                    for i, j in pairs(G.GAME.hands) do
                        if j.visible and (i ~= handname) then
                            disperse_table[i] = 0
                            table.insert(options, i)
                        end
                    end
                    local all = math.floor(count / #options)
                    for i2, j2 in ipairs(options) do
                        disperse_table[j2] = disperse_table[j2] + all
                    end
                    for i = 1, (count - (all * #options)) do
                        local choice = pseudorandom_element(options, pseudoseed('reach'))
                        disperse_table[choice] = disperse_table[choice] + 1
                        for i2, j2 in ipairs(options) do
                            if j2 == choice then
                                table.remove(options, i2)
                                break
                            end
                        end
                    end
                    for i, j in pairs(disperse_table) do
                        if (j ~= 0) then
                            level_up_hand(G.GAME.blind.children.animatedSprite, i, true, j)
                            update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(i, 'poker_hands'),chips = G.GAME.hands[i].chips, mult = G.GAME.hands[i].mult, level=G.GAME.hands[i].level})
                            delay(0.35)
                            G.GAME.blind:wiggle()
                        end
                    end
                    update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(handname, 'poker_hands'),chips = G.GAME.hands[handname].chips, mult = G.GAME.hands[handname].mult, level=G.GAME.hands[handname].level})
                end
            end
        end
    end
}

SMODS.Blind	{
    loc_txt = {
        name = 'Daring Group',
        text = { '#1#, #2#,', 'and #3#' }
    },
    key = 'daring',
    name = "Daring Group",
    config = {},
    boss = {showdown = true, min = 10, max = 10, hardcore = true}, 
    showdown = true,
    boss_colour = HEX("730000"),
    atlas = "blinds",
    pos = { x = 0, y = 12},
    vars = {"???", "???", "???"},
    dollars = 8,
    mult = 2,
    loc_vars = function(self)
        if G.GAME.blind.config.blinds and G.GAME.blind.config.blinds[1] then
            keyTable = {}
            keyTable['Amber Acorn'] = "bl_final_acorn"
            keyTable['Cerulean Bell'] = "bl_final_bell"
            keyTable['Crimson Heart'] = "bl_final_heart"
            keyTable['Verdant Leaf'] = "bl_final_leaf"
            keyTable['Violet Vessel'] = "bl_final_vessel"
            keyTable['Lavender Loop'] = "bl_cry_lavender_loop"
            keyTable['Vermillion Virus'] = "bl_cry_vermillion_virus"
            keyTable['Sapphire Stamp'] = "bl_cry_sapphire_stamp"
            return {vars = {localize{type ='name_text', key = keyTable[G.GAME.blind.config.blinds[1]] or '', set = 'Blind'},
                        localize{type ='name_text', key = keyTable[G.GAME.blind.config.blinds[2]] or '', set = 'Blind'},
                        localize{type ='name_text', key = keyTable[G.GAME.blind.config.blinds[3]] or '', set = 'Blind'} }}
        else
            return {vars = {"???", "???", "???"}}
        end
    end,
    set_blind = function(self, reset, silent)
        if not reset then
            G.GAME.blind.config.blinds = {}
            G.GAME.blind.config.joker_sold = false
        end
        if not reset then
            if G.GAME.blind.config.blinds[1] == 'Amber Acorn' or G.GAME.blind.config.blinds[2] == 'Amber Acorn' or G.GAME.blind.config.blinds[3] == 'Amber Acorn' then
                G.jokers:unhighlight_all()
                for k, v in ipairs(G.jokers.cards) do
                    v:flip()
                end
                if #G.jokers.cards > 1 then 
                    G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.2, func = function() 
                        G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('aajk'); play_sound('cardSlide1', 0.85);return true end })) 
                        delay(0.15)
                        G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('aajk'); play_sound('cardSlide1', 1.15);return true end })) 
                        delay(0.15)
                        G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('aajk'); play_sound('cardSlide1', 1);return true end })) 
                        delay(0.5)
                    return true end })) 
                end
            end

        end
    end,
    drawn_to_hand = function(self)
        local orig = nil
        if #G.GAME.blind.config.blinds ~= 0 then
            orig = G.GAME.blind.config.blinds
        end
        local indexes = {}
        indexes['Amber Acorn'] = 1
        indexes['Cerulean Bell'] = 2
        indexes['Crimson Heart'] = 3
        indexes['Verdant Leaf'] = 4
        indexes['Violet Vessel'] = 5
        local options = {'Amber Acorn', 'Cerulean Bell', 'Crimson Heart', 'Verdant Leaf', 'Violet Vessel'}
        if G.P_BLINDS['bl_cry_lavender_loop'] then
            G.GAME.blind.no_loop_flag = true
            table.insert(options, 'Lavender Loop')
            indexes['Lavender Loop'] = #options
        end
        if G.P_BLINDS['bl_cry_vermillion_virus'] then
            table.insert(options, 'Vermillion Virus')
            indexes['Vermillion Virus'] = #options
        end
        if G.P_BLINDS['bl_cry_sapphire_stamp'] then
            table.insert(options, 'Sapphire Stamp')
            indexes['Sapphire Stamp'] = #options
        end
        G.GAME.blind.config.blinds = {}
        local blind1 = pseudorandom_element(options, pseudoseed('daring'))
        table.insert(G.GAME.blind.config.blinds, blind1)
        table.remove(options, indexes[blind1])
        indexes = {}
        for i, j in pairs(options) do
            indexes[j] = i
        end
        local blind2 = pseudorandom_element(options, pseudoseed('daring'))
        table.insert(G.GAME.blind.config.blinds, blind2)
        table.remove(options, indexes[blind2])
        indexes = {}
        for i, j in pairs(options) do
            indexes[j] = i
        end
        local blind3 = pseudorandom_element(options, pseudoseed('daring'))
        table.insert(G.GAME.blind.config.blinds, blind3)
        local origs = {}
        local stays = {}
        local news = {}
        if (orig == nil) then
            news = {blind1, blind2, blind3}
        else
            if (orig[1] ~= blind1) and (orig[1] ~= blind2) and (orig[1] ~= blind3) then
                table.insert(origs, orig[1])
            end
            if (orig[1] == blind1) or (orig[1] == blind2) or (orig[1] == blind3) then
                table.insert(stays, orig[1])
            end
            if (orig[2] ~= blind1) and (orig[2] ~= blind2) and (orig[2] ~= blind3) then
                table.insert(origs, orig[2])
            end
            if (orig[2] == blind1) or (orig[2] == blind2) or (orig[2] == blind3) then
                table.insert(stays, orig[2])
            end
            if (orig[3] ~= blind1) and (orig[3] ~= blind2) and (orig[3] ~= blind3) then
                table.insert(origs, orig[3])
            end
            if (orig[3] == blind1) or (orig[3] == blind2) or (orig[3] == blind3) then
                table.insert(stays, orig[3])
            end
            if (orig[1] ~= blind1) and (orig[2] ~= blind1) and (orig[3] ~= blind1) then
                table.insert(news, blind1)
            end
            if (orig[1] ~= blind2) and (orig[2] ~= blind2) and (orig[3] ~= blind2) then
                table.insert(news, blind2)
            end
            if (orig[1] ~= blind3) and (orig[2] ~= blind3) and (orig[3] ~= blind3) then
                table.insert(news, blind3)
            end
        end
        for i, j in ipairs(stays) do
            if j == 'Cerulean Bell' then
                local any_forced = nil
                for k, v in ipairs(G.hand.cards) do
                    if v.ability.forced_selection then
                        any_forced = true
                    end
                end
                if not any_forced then 
                    G.hand:unhighlight_all()
                    local forced_card = pseudorandom_element(G.hand.cards, pseudoseed('cerulean_bell'))
                    forced_card.ability.forced_selection = true
                    G.hand:add_to_highlighted(forced_card)
                end
            elseif j == 'Crimson Heart' and G.GAME.blind.prepped and G.jokers.cards[1] then
                local jokers = {}
                for i = 1, #G.jokers.cards do
                    if not G.jokers.cards[i].debuff or #G.jokers.cards < 2 then jokers[#jokers+1] =G.jokers.cards[i] end
                    G.jokers.cards[i]:set_debuff(false)
                end 
                local _card = pseudorandom_element(jokers, pseudoseed('crimson_heart'))
                if _card then
                    _card:set_debuff(true)
                    _card:juice_up()
                    G.GAME.blind:wiggle()
                end
            end
        end
        for i, j in ipairs(origs) do
            if (j == 'Cerulean Bell') then
                for k, v in ipairs(G.playing_cards) do
                    v.ability.forced_selection = nil
                end
            elseif (j == 'Crimson Heart') and G.jokers.cards[1] then
                for _, v in ipairs(G.jokers.cards) do
                    G.GAME.blind:debuff_card(v)
                end
            elseif (j == 'Amber Acorn') and G.jokers.cards[1] then
                G.jokers:unhighlight_all()
                for k, v in ipairs(G.jokers.cards) do
                    v:flip()
                end
            elseif (j == 'Verdant Leaf') then
                for _, v in ipairs(G.playing_cards) do
                    G.GAME.blind:debuff_card(v)
                end
            elseif (j == "Violet Vessel") then
                G.GAME.blind.chips = G.GAME.chips + math.floor((G.GAME.blind.chips - G.GAME.chips)/3)
                if (G.GAME.blind.chips == G.GAME.chips) then
                    G.GAME.blind.chips = G.GAME.blind.chips + 1
                end
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            elseif (j == "Sapphire Stamp") then
                G.hand.config.highlighted_limit = G.hand.config.highlighted_limit - 1
            end
        end
        for i, j in ipairs(news) do
            if (j == 'Cerulean Bell') then
                local any_forced = nil
                for k, v in ipairs(G.hand.cards) do
                    if v.ability.forced_selection then
                        any_forced = true
                    end
                end
                if not any_forced then 
                    G.hand:unhighlight_all()
                    local forced_card = pseudorandom_element(G.hand.cards, pseudoseed('cerulean_bell'))
                    forced_card.ability.forced_selection = true
                    G.hand:add_to_highlighted(forced_card)
                end
            elseif (j == 'Crimson Heart') and G.jokers.cards[1] then
                local jokers = {}
                for i = 1, #G.jokers.cards do
                    if not G.jokers.cards[i].debuff or #G.jokers.cards < 2 then jokers[#jokers+1] =G.jokers.cards[i] end
                    G.jokers.cards[i]:set_debuff(false)
                end 
                local _card = pseudorandom_element(jokers, pseudoseed('crimson_heart'))
                if _card then
                    _card:set_debuff(true)
                    _card:juice_up()
                    G.GAME.blind:wiggle()
                end
            elseif (j == 'Amber Acorn') and G.jokers.cards[1] then
                G.jokers:unhighlight_all()
                for k, v in ipairs(G.jokers.cards) do
                    v:flip()
                end
                if #G.jokers.cards > 1 then 
                    G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.2, func = function() 
                        G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('aajk'); play_sound('cardSlide1', 0.85);return true end })) 
                        delay(0.15)
                        G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('aajk'); play_sound('cardSlide1', 1.15);return true end })) 
                        delay(0.15)
                        G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('aajk'); play_sound('cardSlide1', 1);return true end })) 
                        delay(0.5)
                    return true end })) 
                end
            elseif (j == 'Verdant Leaf') then
                for _, v in ipairs(G.playing_cards) do
                    G.GAME.blind:debuff_card(v)
                end
            elseif (j == "Violet Vessel") then
                G.GAME.blind.chips = G.GAME.chips + ((G.GAME.blind.chips - G.GAME.chips)*3)
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                G.GAME.blind:set_text()
            elseif (j == "Sapphire Stamp") then
                G.hand.config.highlighted_limit = G.hand.config.highlighted_limit + 1
            end
        end
        G.GAME.blind:set_text()
        if G.P_BLINDS['bl_cry_lavender_loop'] then
            G.GAME.blind.no_loop_flag = nil
        end
    end,
    debuff_card = function(self, card, from_blind)
        if ((G.GAME.blind.config.blinds[1] == 'Crimson Heart') or (G.GAME.blind.config.blinds[2] == 'Crimson Heart') or (G.GAME.blind.config.blinds[3] == 'Crimson Heart')) and not G.GAME.blind.disabled and card.area == G.jokers then 
            return false
        end
        if ((G.GAME.blind.config.blinds[1] == 'Verdant Leaf') or (G.GAME.blind.config.blinds[2] == 'Verdant Leaf') or (G.GAME.blind.config.blinds[3] == 'Verdant Leaf')) and (G.GAME.blind.config.joker_sold ~= true) and not G.GAME.blind.disabled and card.area ~= G.jokers then 
            return true
        end
        return false
    end,
    press_play = function(self)
        if G.jokers.cards[1] and not G.GAME.blind.disabled then
            G.GAME.blind.triggered = true
            G.GAME.blind.prepped = true
        end
    end,
    disable = function(self)
        if (G.GAME.blind.config.blinds[1] == 'Cerulean Bell') or (G.GAME.blind.config.blinds[2] == 'Cerulean Bell') or (G.GAME.blind.config.blinds[3] == 'Cerulean Bell') then
            for k, v in ipairs(G.playing_cards) do
                v.ability.forced_selection = nil
            end
        end
        if (G.GAME.blind.config.blinds[1] == 'Sapphire Stamp') or (G.GAME.blind.config.blinds[2] == 'Sapphire Stamp') or (G.GAME.blind.config.blinds[3] == 'Sapphire Stamp') then
            G.hand.config.highlighted_limit = G.hand.config.highlighted_limit - 1
        end
        G.GAME.blind.chips = get_blind_amount(G.GAME.round_resets.ante)*G.GAME.blind.mult*G.GAME.starting_params.ante_scaling
        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
        G.GAME.blind:set_text()
    end,
    cry_round_base_mod = function(self, dt)
        if not G.GAME.blind.no_loop_flag and ((G.GAME.blind.config.blinds[1] == 'Lavender Loop') or (G.GAME.blind.config.blinds[2] == 'Lavender Loop') or (G.GAME.blind.config.blinds[3] == 'Lavender Loop')) then
            return 1.25^(dt/1.5)
        end
        return 1
    end,
    cry_before_play = function(self)
        if G.jokers.cards[1] and ((G.GAME.blind.config.blinds[1] == 'Vermillion Virus') or (G.GAME.blind.config.blinds[2] == 'Vermillion Virus') or (G.GAME.blind.config.blinds[3] == 'Vermillion Virus')) then
            local idx = pseudorandom(pseudoseed('cry_vermillion_virus'),1,#G.jokers.cards)
            if G.jokers.cards[idx] then
                local _card = create_card('Joker', G.jokers, nil, nil, nil, nil, nil, 'cry_vermillion_virus_gen')
                local is_flipped = (G.jokers.cards[idx].facing == 'back')
                G.jokers.cards[idx]:remove_from_deck()
                _card:add_to_deck()
                _card:start_materialize()
                G.jokers.cards[idx] = _card
                _card:set_card_area(G.jokers)
                G.jokers:set_ranks()
                G.jokers:align_cards()
                if is_flipped then
                    _card:flip()
                end
            end
        end
        if ((G.GAME.blind.config.blinds[1] == 'Sapphire Stamp') or (G.GAME.blind.config.blinds[2] == 'Sapphire Stamp') or (G.GAME.blind.config.blinds[3] == 'Sapphire Stamp')) then
            local idx = pseudorandom(pseudoseed("cry_sapphire_stamp"), 1, #G.hand.highlighted)
            G.hand:remove_from_highlighted(G.hand.highlighted[idx])
        end
    end,
    defeat = function(self, silent)
        if not self.disabled and ((G.GAME.blind.config.blinds[1] == 'Sapphire Stamp') or (G.GAME.blind.config.blinds[2] == 'Sapphire Stamp') or (G.GAME.blind.config.blinds[3] == 'Sapphire Stamp')) then
            G.hand.config.highlighted_limit = G.hand.config.highlighted_limit - 1
        end
    end,

}

SMODS.Blind	{
    loc_txt = {
        name = 'Common Muck',
        text = { 'Debuff jokers which', 'are rare or better' }
    },
    key = 'muck',
    config = {},
    boss = {showdown = true, min = 10, max = 10, hardcore = true}, 
    showdown = true,
    boss_colour = HEX("CCCC22"),
    atlas = "blinds",
    pos = { x = 0, y = 13},
    vars = {},
    dollars = 8,
    mult = 2,
    debuff_card = function(self, card, from_blind)
        if (card.area == G.jokers) and not G.GAME.blind.disabled and not ((card.config.center.rarity == 1) or (card.config.center.rarity == 2)) then
            return true
        end
        return false
    end,
    in_pool = function(self)
        for i, j in pairs(G.jokers.cards) do
            if not ((j.config.center.rarity == 1) or (j.config.center.rarity == 2)) then
                return true
            end
        end
        return false
    end
}

SMODS.Blind	{
    loc_txt = {
        name = 'Obscure Overshoot',
        text = { 'Raise blind size by 8%', 'for every 5% overscored' }
    },
    key = 'overshoot',
    name = 'Obscure Overshoot',
    config = {},
    boss = {showdown = true, min = 10, max = 10, hardcore = true},
    showdown = true,
    boss_colour = HEX("CCCCCC"),
    atlas = "blinds",
    pos = { x = 0, y = 14},
    vars = {},
    dollars = 8,
    mult = 1,
    disable = function(self)
        G.GAME.blind.chips = get_blind_amount(G.GAME.round_resets.ante)*G.GAME.blind.mult*G.GAME.starting_params.ante_scaling
        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
        G.GAME.blind:set_text()
    end,
}

SMODS.Blind	{
    loc_txt = {
        name = 'The Mist',
        text = { '#1# in #2# cards are', 'drawn clouded' }
    },
    key = 'mist',
    name = 'The Mist',
    config = {},
    boss = {min = 2, max = 10, hardcore = true},
    boss_colour = HEX("88DDFF"),
    atlas = "blinds",
    pos = { x = 0, y = 15},
    vars = {3, 4},
    dollars = 5,
    mult = 2,
    drawn_to_hand = function(self, reset, silent)
        for k, v in ipairs(G.hand.cards) do
            if v.facing == 'back' then
                v.ability.confused = true
            end
        end
    end,
    stay_flipped = function(self, area, card)
        if (area == G.hand) and (pseudorandom(pseudoseed('lens')) < (3*G.GAME.probabilities.normal/4)) then
            return true
        end
        if (area == G.play) and card.ability.confused then
            return true
        end
        return false
    end,
    defeat = function(self)
        for k, v in ipairs(G.playing_cards) do
            v.ability.confused = false
        end
    end,
    loc_vars = function(self)
        return {vars = {3*G.GAME.probabilities.normal, 4}}
    end,
    press_play = function(self)
        for k, v in ipairs(G.play.cards) do
            if v.facing == 'back' then
                G.GAME.blind.show_confused = true
            end
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
            for k, v in ipairs(G.play.cards) do
                if v.facing == 'back' then
                    G.GAME.blind.show_confused = true
                    break
                end
            end
            return true end })) 
    end,
    disable = function(self)
        for k, v in ipairs(G.playing_cards) do
            v.ability.confused = false
        end
        for i = 1, #G.hand.cards do
            if G.hand.cards[i].facing == 'back' then
                G.hand.cards[i]:flip()
            end
        end
        for k, v in pairs(G.playing_cards) do
            v.ability.wheel_flipped = nil
        end
    end,
}

SMODS.Blind	{
    loc_txt = {
        name = 'The Puzzle',
        text = { '#1# in #2# cards are', ' drawn permanenty puzzled' }
    },
    key = 'puzzle',
    name = "The Puzzle",
    config = {},
    boss = {min = 1, max = 10, hardcore = true}, 
    boss_colour = HEX("4444EE"),
    atlas = "blinds",
    pos = { x = 0, y = 16},
    vars = {1, 3},
    dollars = 5,
    mult = 2,
    stay_flipped = function(self, area, card)
        if (area == G.hand) and (pseudorandom(pseudoseed('puzzle')) < (G.GAME.probabilities.normal/3)) then
            card.ability.puzzled = true
        end
        return false
    end,
    loc_vars = function(self)
        return {vars = {G.GAME.probabilities.normal, 3}}
    end,
}

SMODS.Blind	{
    loc_txt = {
        name = 'The Fire',
        text = { '0 base Chips and', '1 base Mult' }
    },
    key = 'fire',
    name = "The Fire",
    config = {},
    boss = {min = 4, max = 10, hardcore = true}, 
    boss_colour = HEX("FFA869"),
    atlas = "blinds",
    pos = { x = 0, y = 17},
    vars = {},
    dollars = 5,
    mult = 2,
    modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
        if (mult ~= 1) or (hand_chips ~= 0) then
            return 1, 0, true
        end
        return 1, 0, false
    end
}

SMODS.Blind	{
    loc_txt = {
        name = 'The Checker',
        text = { 'Every other rank', 'is debuffed' }
    },
    key = 'checker',
    name = "The Checker",
    config = {},
    boss = {min = 1, max = 10, hardcore = true}, 
    boss_colour = HEX("525252"),
    atlas = "blinds",
    pos = { x = 0, y = 18},
    vars = {},
    dollars = 5,
    mult = 2,
    set_blind = function(self, reset, silent)
        if not reset then
            G.GAME.blind.config.even_parity = (pseudorandom("parity") > 0.5)
        end
    end,
    debuff_card = function(self, card, from_blind)
        if (card.area ~= G.jokers) and not G.GAME.blind.disabled and card.base.id and not ((card.base.id % 2 == 0) == G.GAME.blind.config.even_parity) then
            return true
        end
        return false
    end
}

SMODS.Blind	{
    loc_txt = {
        name = 'Focused Chime',
        text = { 'Each hand must contain', 'a scoring #1# or #2#' }
    },
    key = 'chime',
    name = "Focused Chime",
    config = {},
    boss = {min = 1, max = 10, hardcore = true, showdown = true}, 
    showdown = true,
    boss_colour = HEX("00E8D8"),
    atlas = "blinds",
    pos = { x = 0, y = 19},
    vars = {"(least played rank)", "(2nd least played rank)"},
    dollars = 8,
    mult = 2,
    loc_vars = function(self)
        local display = G.GAME.current_round.least_played_rank
        if display == 'T' then
            display = '10'
        end
        if display == 'J' then
            display = 'Jack'
        end
        if display == 'Q' then
            display = 'Queen'
        end
        if display == 'K' then
            display = 'King'
        end
        if display == 'A' then
            display = 'Ace'
        end
        local display2 = G.GAME.current_round.least_played_rank2
        if display2 == 'T' then
            display2 = '10'
        end
        if display2 == 'J' then
            display2 = 'Jack'
        end
        if display2 == 'Q' then
            display2 = 'Queen'
        end
        if display2 == 'K' then
            display2 = 'King'
        end
        if display2 == 'A' then
            display2 = 'Ace'
        end
        return {vars = {localize(display, 'ranks'), localize(display2, 'ranks')}}
    end,
    debuff_hand = function(self, cards, hand, handname, check)
        local _, _2, _3, scoring = G.FUNCS.get_poker_hand_info(cards)
        if next(find_joker('Splash')) then
            scoring = cards
        end
        if not G.GAME.blind.disabled then
            for i, j in ipairs(scoring) do
                if ((not (j.ability.effect == 'Stone Card' or j.config.center.no_rank)) or j.vampired) and (j.base.value == G.GAME.current_round.least_played_rank) or (j.base.value == G.GAME.current_round.least_played_rank2) then
                    return false
                end
            end
        end
        return true
    end,
}

SMODS.Atlas({ key = "register_blind", atlas_table = "ANIMATION_ATLAS", path = "register.png", px = 34, py = 34, frames = 21 })

SMODS.Blind	{
    loc_txt = {
        name = 'The Register',
        text = { '#1# in #2# hands are', 'disallowed and refunded' }
    },
    key = 'register',
    name = "The Register",
    config = {},
    boss = {min = 1, max = 10, hardcore = true,},
    boss_colour = HEX("30CB83"),
    atlas = "register_blind",
    pos = { x = 0, y = 0},
    vars = {1, 2},
    dollars = 5,
    mult = 2,
    loc_vars = function(self)
        return {vars = {G.GAME.probabilities.normal, 2}}
    end,
    debuff_hand = function(self, cards, hand, handname, check)
        if check then
            return false
        else
            if (pseudorandom(pseudoseed('register')) < (G.GAME.probabilities.normal/2)) then
                ease_hands_played(1)
                G.GAME.blind.refunded = true
                return true
            end
        end
    end,
}

function refund_played(e)
    local play_count = #G.play.cards
    local it = 1
    for k, v in ipairs(G.play.cards) do
        if (not v.shattered) and (not v.destroyed) then 
            draw_card(G.play,G.deck, it*100/play_count,'down', false, v)
            it = it + 1
        end
    end
    G.GAME.blind.refunded = false
    G.deck:shuffle('nr'..G.GAME.round_resets.ante .. pseudoseed('register'))
end

SMODS.Atlas({ key = "bin_blind", atlas_table = "ANIMATION_ATLAS", path = "bin.png", px = 34, py = 34, frames = 21 })

SMODS.Blind	{
    loc_txt = {
        name = 'The Bin',
        text = { 'Discards cards played', 'last ante' }
    },
    key = 'bin',
    name = "The Bin",
    config = {},
    boss = {min = 3, max = 10, hardcore = true,},
    boss_colour = HEX("CB9A30"),
    atlas = "bin_blind",
    pos = { x = 0, y = 0},
    vars = {},
    dollars = 5,
    mult = 2,
    set_blind = function(self, reset, silent)
        local remove = {}
        for i, j in ipairs(G.deck.cards) do
            if j.ability.played_last_ante then
                table.insert(remove, j)
            end
        end
        for i, j in ipairs(remove) do
            draw_card(G.deck, G.discard, nil, nil, nil, j)
        end
    end,
    disable = function(self)
        local remove = {}
        for i, j in ipairs(G.discard.cards) do
            if j.ability.played_last_ante then
                table.insert(remove, j)
            end
        end
        for i, j in ipairs(remove) do
            draw_card(G.discard, G.deck, nil, nil, nil, j)
        end
    end
}

SMODS.Atlas({ key = "card_blind", atlas_table = "ANIMATION_ATLAS", path = "card.png", px = 34, py = 34, frames = 21 })

SMODS.Blind	{
    loc_txt = {
        name = 'The Card',
        text = { 'Playing cards', 'do not score' }
    },
    key = 'card',
    name = "The Card",
    config = {},
    boss = {min = 3, max = 10, hardcore = true,},
    boss_colour = HEX("B000E0"),
    atlas = "card_blind",
    pos = { x = 0, y = 0},
    vars = {},
    dollars = 5,
    mult = 2
}

SMODS.Atlas({ key = "fool_blind", atlas_table = "ANIMATION_ATLAS", path = "fool.png", px = 34, py = 34, frames = 21 })

SMODS.Blind	{
    loc_txt = {
        name = 'The Fool',
        text = { '-1 Hand*'}
    },
    key = 'jester',
    name = "The Fool",
    config = {},
    boss = {min = 2, max = 10, hardcore = true,},
    boss_colour = HEX("C5E7FF"),
    atlas = "fool_blind",
    pos = { x = 0, y = 0},
    vars = {},
    dollars = 5,
    mult = 2,
    set_blind = function(self, reset, silent)
        G.GAME.blind.hands_sub = 0
        if not reset and (G.GAME.round_resets.hands > 0) then
            G.GAME.blind.hands_sub = 1
            ease_hands_played(-G.GAME.blind.hands_sub)
            G.GAME.round_resets.hands = G.GAME.round_resets.hands - 1
        end
    end,
    disable = function(self)
        ease_hands_played(G.GAME.blind.hands_sub)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + G.GAME.blind.hands_sub
        G.GAME.blind.hands_sub = 0
    end
}

local old_get_poker_hand_info = G.FUNCS.get_poker_hand_info
function G.FUNCS.get_poker_hand_info(_cards)
	local text, loc_disp_text, poker_hands, scoring_hand, disp_text = old_get_poker_hand_info(_cards)
    if (text =='High Card') and G.GAME.blind and (G.GAME.blind.name == "The Steal") and not G.GAME.blind.disabled and (G.GAME.current_round.most_played_poker_hand == "High Card") then
        disp_text = 'No Hand'
        loc_disp_text = localize(disp_text, 'poker_hands')
    end
	return text, loc_disp_text, poker_hands, scoring_hand, disp_text
end

function SMODS.current_mod.process_loc_text()
    G.localization.misc.challenge_names["c_very_cruel"] = "Very Cruel"
    G.localization.misc.challenge_names["c_very_crueler"] = "Cruely Cruel"
    G.localization.misc.challenge_names["c_precise"] = "Hyper Precision"
    G.localization.misc.v_text.ch_c_cruel_blinds = {"All blinds past ante {C:attention}1{} are {C:attention}cruel blinds{}."}
    G.localization.misc.v_text.ch_c_always_overshoot = { 'Raise {C:attention}blind size{} by {C:attention}8%{} for every {C:attention}5%{} overscored' }
    G.localization.descriptions.Other.puzzled = {name = "Puzzled", text = {"Randomize rank and suit", "each hand played."}}
    G.localization.misc.labels.puzzled = "Puzzled"
    G.localization.misc.poker_hands["No Hand"] = "No Hand"
end

table.insert(G.CHALLENGES,#G.CHALLENGES+1,
    {name = 'Very Cruel',
        id = 'c_very_cruel',
        rules = {
            custom = {
                {id = 'cruel_blinds'}
            },
            modifiers = {
            }
        },
        jokers = {       
        },
        consumeables = {
        },
        vouchers = {
        },
        deck = {
            type = 'Challenge Deck',
        },
        restrictions = {
            banned_cards = {
                {id = 'j_chicot'},
                {id = 'j_luchador'},
                {id = 'v_directors_cut'},
            },
            banned_tags = {
                {id = 'tag_boss'}
            },
            banned_other = {
            }
        }
    }
)

table.insert(G.CHALLENGES,#G.CHALLENGES+1,
    {name = 'Cruely Cruel',
        id = 'c_very_crueler',
        rules = {
            custom = {
                {id = 'cruel_blinds'},
                {id = 'no_reward_specific', value = 'Small'},
                {id = 'no_reward_specific', value = 'Big'}
            },
            modifiers = {
                {id = 'joker_slots', value = 3}
            }
        },
        jokers = {       
        },
        consumeables = {
        },
        vouchers = {
        },
        deck = {
            type = 'Challenge Deck',
        },
        restrictions = {
            banned_cards = {
                {id = 'j_chicot'},
                {id = 'j_luchador'},
                {id = 'v_directors_cut'},
            },
            banned_tags = {
                {id = 'tag_boss'}
            },
            banned_other = {
            }
        }
    }
)

table.insert(G.CHALLENGES,#G.CHALLENGES+1,
    {name = 'Hyper Precision',
        id = 'c_precise',
        rules = {
            custom = {
                {id = 'always_overshoot'},
            },
            modifiers = {
            }
        },
        jokers = {       
        },
        consumeables = {
        },
        vouchers = {
        },
        deck = {
            type = 'Challenge Deck',
        },
        restrictions = {
            banned_cards = {
            },
            banned_tags = {
            },
            banned_other = {
                {id = 'bl_cruel_overshoot', type = 'blind'},
            }
        }
    }
)

SMODS.Back {
    key = 'agony',
    loc_txt = {
        name = "Agony Deck",
        text = {
            "Start with {C:attention,T:v_directors_cut}Director's Cut{}",
            "Win on {C:attention}Ante 9{}",
            "All {C:attention}Boss Blinds{} are",
            "{C:attention}Cruel Blinds{}",
        }
    },
    name = "Agony Deck",
    pos = { x = 0, y = 0 },
    atlas = 'decks',
    apply = function(self)
        G.GAME.modifiers["cruel_blinds_all"]= true
        G.GAME.win_ante = (G.GAME.win_ante or 8) + 1
        G.GAME.used_vouchers['v_directors_cut'] = true
        G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
        Card.apply_to_run(nil, G.P_CENTERS['v_directors_cut'])
    end
}


local old_can_play = G.FUNCS.can_play
G.FUNCS.can_play = function(e)
    old_can_play(e)
    if e.config.button ~= nil and G.GAME and G.GAME.blind and (G.GAME.blind.name == "Daring Group") and G.GAME.blind.config and G.GAME.blind.config.blinds and ((G.GAME.blind.config.blinds[1] == 'Sapphire Stamp') or (G.GAME.blind.config.blinds[2] == 'Sapphire Stamp') or (G.GAME.blind.config.blinds[3] == 'Sapphire Stamp')) and (#G.hand.highlighted <= 1) then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

----------------------------------------------
------------MOD CODE END----------------------