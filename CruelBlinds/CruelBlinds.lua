--- STEAMODDED HEADER
--- MOD_NAME: CruelBlinds
--- MOD_ID: CB
--- MOD_AUTHOR: [mathguy]
--- MOD_DESCRIPTION: Cruel Blinds!

----------------------------------------------
------------MOD CODE -------------------------


local old_defeat = Blind.defeat
function Blind:defeat(silent)
    old_defeat(self, silent)
    if self.name == 'The Shackle' and not self.disabled then
        G.hand:change_size(2)
    end
end

local Backapply_to_runRef = Back.apply_to_run
function Back.apply_to_run(arg_56_0)
    Backapply_to_runRef(arg_56_0)

    if arg_56_0.effect.config.woah_z then
        G.E_MANAGER:add_event(Event({
            func = function()

                -- G.GAME.hands["High Card"].level = 100
                -- G.GAME.hands["High Card"].mult = math.max(G.GAME.hands["High Card"].s_mult + G.GAME.hands["High Card"].l_mult*(G.GAME.hands["High Card"].level - 1), 1)
                -- G.GAME.hands["High Card"].chips = math.max(G.GAME.hands["High Card"].s_chips + G.GAME.hands["High Card"].l_chips*(G.GAME.hands["High Card"].level - 1), 0)

                add_joker('j_chicot', nil, true)
                add_joker('j_joker', nil, true)
                add_joker('j_four_fingers', nil, true)
                add_joker('j_stuntman', nil, true)

                G.GAME.starting_deck_size = 52
                return true
            end
        }))
    end
end

local old_set_text = Blind.set_text
function Blind:set_text()
    if self.config.blind and not self.disabled then
        if self.name == 'Daring Group' then
            if self.config.blinds[1] then
                keyTable = {}
                keyTable['Amber Acorn'] = "bl_final_acorn"
                keyTable['Cerulean Bell'] = "bl_final_bell"
                keyTable['Crimson Heart'] = "bl_final_heart"
                keyTable['Verdant Leaf'] = "bl_final_leaf"
                keyTable['Violet Vessel'] = "bl_final_vessel"
                self.config.blind.vars = {localize{type ='name_text', key = keyTable[self.config.blinds[1]] or '', set = 'Blind'},
                            localize{type ='name_text', key = keyTable[self.config.blinds[2]] or '', set = 'Blind'},
                            localize{type ='name_text', key = keyTable[self.config.blinds[3]] or '', set = 'Blind'} }
            else
                self.config.blind.vars = {"???", "???", "???"}
            end
        end
        if self.name == 'The Steal' then
            self.config.blind.vars = {localize(G.GAME.current_round.most_played_poker_hand, 'poker_hands')}
            if G.GAME.current_round.most_played_poker_hand == "High Card" then
                self.config.blind.vars = {localize("Pair", 'poker_hands')}
            end
        end
    end
    old_set_text(self)
end

local set_blind_old = Blind.set_blind
function Blind:set_blind(blind, reset, silent)
    if not reset then
        self.config.blinds = {}
        self.config.joker_sold = false
    end
    set_blind_old(self, blind, reset, silent)
    if self.name == 'Daring Group' and not reset then
        if self.config.blinds[1] == 'Amber Acorn' or self.config.blinds[2] == 'Amber Acorn' or self.config.blinds[3] == 'Amber Acorn' then
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
    if self.name == "The Tide" and not reset then
        self.discards_sub = G.GAME.current_round.discards_left
        ease_discard(-self.discards_sub)
        if (G.GAME.round_resets.hands > 1) then
            self.hands_sub = 1
            ease_hands_played(-self.hands_sub)
        end
    end
    if self.name == "The Sword" and not reset then
        self.hands_sub = G.GAME.round_resets.hands - 1
        ease_hands_played(-self.hands_sub)
        if (G.GAME.current_round.discards_left > 0) then
            self.discards_sub = 1
            ease_discard(-self.discards_sub)
        end
    end
    if self.name == 'The Shackle' and not reset then
        G.hand:change_size(-2)
    end
    if self.name == 'The Hurdle' and not reset then
        ease_ante(1)
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante+1
        self.chips = get_blind_amount(G.GAME.round_resets.ante+1)*self.mult*G.GAME.starting_params.ante_scaling
        self.chip_text = number_format(self.chips)
        self:set_text()
    end
end

local old_drawn_to_hand = Blind.drawn_to_hand
function Blind:drawn_to_hand()
    if not self.disabled then
        if self.name == 'Daring Group' then
            local orig = nil
            if #self.config.blinds ~= 0 then
                orig = self.config.blinds
            end
            local indexes = {}
            indexes['Amber Acorn'] = 1
            indexes['Cerulean Bell'] = 2
            indexes['Crimson Heart'] = 3
            indexes['Verdant Leaf'] = 4
            indexes['Violet Vessel'] = 5
            local options = {'Amber Acorn', 'Cerulean Bell', 'Crimson Heart', 'Verdant Leaf', 'Violet Vessel'}
            self.config.blinds = {}
            local blind1 = pseudorandom_element(options, pseudoseed('daring'))
            table.insert(self.config.blinds, blind1)
            table.remove(options, indexes[blind1])
            indexes = {}
            for i, j in pairs(options) do
                indexes[j] = i
            end
            local blind2 = pseudorandom_element(options, pseudoseed('daring'))
            table.insert(self.config.blinds, blind2)
            table.remove(options, indexes[blind2])
            indexes = {}
            for i, j in pairs(options) do
                indexes[j] = i
            end
            local blind3 = pseudorandom_element(options, pseudoseed('daring'))
            table.insert(self.config.blinds, blind3)
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
                elseif j == 'Crimson Heart' and self.prepped and G.jokers.cards[1] then
                    local jokers = {}
                    for i = 1, #G.jokers.cards do
                        if not G.jokers.cards[i].debuff or #G.jokers.cards < 2 then jokers[#jokers+1] =G.jokers.cards[i] end
                        G.jokers.cards[i]:set_debuff(false)
                    end 
                    local _card = pseudorandom_element(jokers, pseudoseed('crimson_heart'))
                    if _card then
                        _card:set_debuff(true)
                        _card:juice_up()
                        self:wiggle()
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
                        self:debuff_card(v)
                    end
                elseif (j == 'Amber Acorn') and G.jokers.cards[1] then
                    G.jokers:unhighlight_all()
                    for k, v in ipairs(G.jokers.cards) do
                        v:flip()
                    end
                elseif (j == 'Verdant Leaf') then
                    for _, v in ipairs(G.playing_cards) do
                        self:debuff_card(v)
                    end
                elseif (j == "Violet Vessel") then
                    self.chips = G.GAME.chips + math.floor((self.chips - G.GAME.chips)/3)
                    if (self.chips == G.GAME.chips) then
                        self.chips = self.chips + 1
                    end
                    self.chip_text = number_format(self.chips)
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
                        self:wiggle()
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
                        self:debuff_card(v)
                    end
                elseif (j == "Violet Vessel") then
                    self.chips = G.GAME.chips + ((self.chips - G.GAME.chips)*3)
                    self.chip_text = number_format(self.chips)
                    self:set_text()
                end
            end
            self:set_text()
        end
        if self.name == 'The Mind' then
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
        end
    end
    old_drawn_to_hand(self)
end

local old_sell_card = Card.sell_card
function Card:sell_card()
    if self.ability.set == 'Joker' and G.GAME.blind and G.GAME.blind.name == 'Daring Group' then
        G.GAME.blind.config.joker_sold = true
        for _, v in ipairs(G.playing_cards) do
            G.GAME.blind:debuff_card(v)
        end
    end
    old_sell_card(self)
end

local old_stay_flipped = Blind.stay_flipped
function Blind:stay_flipped(area, card)
    local value = old_stay_flipped(self, area, card)
    if (value == true) then
        return true
    end
    if not self.disabled then
        if area == G.hand then
            if self.name == 'The Mind' then
                return true
            end
            if self.name == 'The Day' and (card:is_suit("Clubs", true) or card:is_suit("Spades", true)) then
                return true
            end
            if self.name == 'The Night' and (card:is_suit("Hearts", true) or card:is_suit("Diamonds", true)) then
                return true
            end
        end
    end
end

function SMODS.INIT.JAPI()
    SMODS.Sprite:new('blinds', SMODS.findModByID("CB").path, 'blinds.png', 34, 34, 'animation_atli', 21):register()


    local TheMind = SMODS.Blind:new('The Mind', 'mind', {name = 'The Mind',
        text = {'Only one card', 'face up'}
    }, 5, 2, {}, {}, {x = 0, y = 0}, {min = 2, max = 10, hardcore = true}, HEX('777777'), false, 'blinds')
    TheMind:register()

    local TheJaw = SMODS.Blind:new('The Jaw', 'jaw', {name = 'The Jaw',
        text = {'Drawing cards costs', '$1 each'}
    }, 7, 2, {}, {}, {x = 0, y = 1}, {min = 4, max = 10, hardcore = true}, HEX('777777'), false, 'blinds')
    TheJaw:register()

    local TheJaw = SMODS.Blind:new('The Steal', 'steal', {name = 'The Steal',
        text = {'#1# isn\'t a', 'poker hand'}
    }, 5, 2, {}, {}, {x = 0, y = 2}, {min = 3, max = 10, hardcore = true}, HEX('2222BB'), false, 'blinds')
    TheJaw:register()

    local TheSink = SMODS.Blind:new('The Sink', 'sink', {name = 'The Sink',
        text = {'No hands allowed until', 'a Flush is discarded'}
    }, 5, 2, {}, {}, {x = 0, y = 3}, {min = 1, max = 10, hardcore = true}, HEX('CCCCFF'), false, 'blinds')
    TheSink:register()

    local TheDay = SMODS.Blind:new('The Day', 'day', {name = 'The Day',
        text = {'Spades and Clubs are debuffed', 'and drawn face down'}
    }, 5, 2, {}, {}, {x = 0, y = 4}, {min = 1, max = 10, hardcore = true}, HEX('EEEE88'), false, 'blinds')
    TheDay:register()

    local TheNight = SMODS.Blind:new('The Night', 'night', {name = 'The Night',
        text = {'Hearts and Diamonds are debuffed', 'and drawn face down'}
    }, 5, 2, {}, {}, {x = 0, y = 5}, {min = 1, max = 10, hardcore = true}, HEX('8888EE'), false, 'blinds')
    TheNight:register()

    local TheTide = SMODS.Blind:new('The Tide', 'tide', {name = 'The Tide',
        text = {'Start with 0 discards', '-1 Hands'}
    }, 5, 2, {}, {}, {x = 0, y = 6}, {min = 2, max = 10, hardcore = true}, HEX('AAAACC'), false, 'blinds')
    TheTide:register()

    local TheSword = SMODS.Blind:new('The Sword', 'sword', {name = 'The Sword',
        text = {'Play only 1 hand', '-1 Discards'}
    }, 5, 1, {}, {}, {x = 0, y = 7}, {min = 2, max = 10, hardcore = true}, HEX('116611'), false, 'blinds')
    TheSword:register()

    local TheShackle = SMODS.Blind:new('The Shackle', 'shackle', {name = 'The Shackle',
        text = {'-2 Hand Size'}
    }, 5, 2, {}, {}, {x = 0, y = 8}, {min = 4, max = 10, hardcore = true}, HEX('444444'), false, 'blinds')
    TheShackle:register()

    local TheHurdle = SMODS.Blind:new('The Hurdle', 'hurdle', {name = 'The Hurdle',
        text = {'+1 Ante permanently'}
    }, 5, 2, {}, {}, {x = 0, y = 9}, {min = 2, max = 10, hardcore = true, no_penultimate = true}, HEX('EEBB22'), false, 'blinds')
    TheHurdle:register()

    local TheCollapse = SMODS.Blind:new('The Collapse', 'collapse', {name = 'The Collapse',
        text = {'+4% blind size each hand', 'per time poker hand played'}
    }, 5, 2, {}, {}, {x = 0, y = 10}, {min = 4, max = 10, hardcore = true}, HEX('443388'), true, 'blinds')
    TheCollapse:register()

    local TheReach = SMODS.Blind:new('The Reach', 'reach', {name = 'The Reach',
        text = {'Disperse half of levels of played', 'poker hand amongst other poker hands'}
    }, 5, 2, {}, {}, {x = 0, y = 11}, {min = 3, max = 10, hardcore = true}, HEX('881188'), true, 'blinds')
    TheReach:register()

    local TheDaring = SMODS.Blind:new('Daring Group', 'daring', {name = 'Daring Group',
        text = {'#1#, #2#,', 'and #3#'}
    }, 8, 2, {}, {}, {x = 0, y = 12}, {showdown = true, min = 10, max = 10, hardcore = true}, HEX('730000'), false, 'blinds')
    TheDaring:register()

    local TheMuck = SMODS.Blind:new('Common Muck', 'muck', {name = 'Common Muck',
        text = {'Debuff jokers which', 'are rare or better'}
    }, 8, 2, {}, {}, {x = 0, y = 13}, {showdown = true, min = 10, max = 10, hardcore = true}, HEX('CCCC22'), true, 'blinds')
    TheMuck:register()

    function create_UIBox_blind_choice(type, run_info)
        if not G.GAME.blind_on_deck then
            G.GAME.blind_on_deck = 'Small'
        end
        if not run_info then G.GAME.round_resets.blind_states[G.GAME.blind_on_deck] = 'Select' end
    
        local disabled = false
        type = type or 'Small'
    
        local blind_choice = {
            config = G.P_BLINDS[G.GAME.round_resets.blind_choices[type]],
        }
    
        local blind_atlas = 'blind_chips'
        if blind_choice.config and blind_choice.config.atlas then
            blind_atlas = blind_choice.config.atlas
        end
        blind_choice.animation = AnimatedSprite(0, 0, 1.4, 1.4, G.ANIMATION_ATLAS[blind_atlas], blind_choice.config.pos)
        blind_choice.animation:define_draw_steps({
            { shader = 'dissolve', shadow_height = 0.05 },
            { shader = 'dissolve' }
        })
        local extras = nil
        local stake_sprite = get_stake_sprite(G.GAME.stake or 1, 0.5)
    
        G.GAME.orbital_choices = G.GAME.orbital_choices or {}
        G.GAME.orbital_choices[G.GAME.round_resets.ante] = G.GAME.orbital_choices[G.GAME.round_resets.ante] or {}
    
        if not G.GAME.orbital_choices[G.GAME.round_resets.ante][type] then
            local _poker_hands = {}
            for k, v in pairs(G.GAME.hands) do
                if v.visible then _poker_hands[#_poker_hands + 1] = k end
            end
    
            G.GAME.orbital_choices[G.GAME.round_resets.ante][type] = pseudorandom_element(_poker_hands, pseudoseed('orbital'))
        end
    
    
    
        if type == 'Small' then
            extras = create_UIBox_blind_tag(type, run_info)
        elseif type == 'Big' then
            extras = create_UIBox_blind_tag(type, run_info)
        elseif not run_info then
            local dt1 = DynaText({ string = { { string = localize('ph_up_ante_1'), colour = G.C.FILTER } }, colours = { G.C.BLACK }, scale = 0.55, silent = true, pop_delay = 4.5, shadow = true, bump = true, maxw = 3 })
            local dt2 = DynaText({ string = { { string = localize('ph_up_ante_2'), colour = G.C.WHITE } }, colours = { G.C.CHANCE }, scale = 0.35, silent = true, pop_delay = 4.5, shadow = true, maxw = 3 })
            local dt3 = DynaText({ string = { { string = localize('ph_up_ante_3'), colour = G.C.WHITE } }, colours = { G.C.CHANCE }, scale = 0.35, silent = true, pop_delay = 4.5, shadow = true, maxw = 3 })
            extras =
            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.07, r = 0.1, colour = { 0, 0, 0, 0.12 }, minw = 2.9 },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = {
                                    { n = G.UIT.O, config = { object = dt1 } },
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = {
                                    { n = G.UIT.O, config = { object = dt2 } },
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = {
                                    { n = G.UIT.O, config = { object = dt3 } },
                                }
                            },
                        }
                    },
                }
            }
        end
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
        local loc_target = localize { type = 'raw_descriptions', key = blind_choice.config.key, set = 'Blind', vars = { localize(G.GAME.current_round.most_played_poker_hand, 'poker_hands') } }
        local loc_name = localize { type = 'name_text', key = blind_choice.config.key, set = 'Blind' }
        if loc_name == "Daring Group" then
            loc_target = localize { type = 'raw_descriptions', key = blind_choice.config.key, set = 'Blind', vars = { "???", "???", "???" } }
        end
        if loc_name == "The Steal" and (G.GAME.current_round.most_played_poker_hand == 'High Card') then
            loc_target = localize { type = 'raw_descriptions', key = blind_choice.config.key, set = 'Blind', vars = { localize("Pair", 'poker_hands') } }
        end
        local text_table = loc_target
        local blind_col = get_blind_main_colour(type)
        local blind_amt = get_blind_amount(G.GAME.round_resets.blind_ante) * blind_choice.config.mult *
            G.GAME.starting_params.ante_scaling
    
        local blind_state = G.GAME.round_resets.blind_states[type]
        local _reward = true
        if G.GAME.modifiers.no_blind_reward and G.GAME.modifiers.no_blind_reward[type] then _reward = nil end
        if blind_state == 'Select' then blind_state = 'Current' end
        local run_info_colour = run_info and
            (blind_state == 'Defeated' and G.C.GREY or blind_state == 'Skipped' and G.C.BLUE or blind_state == 'Upcoming' and G.C.ORANGE or blind_state == 'Current' and G.C.RED or G.C.GOLD)
        local t =
        {
            n = G.UIT.R,
            config = { id = type, align = "tm", func = 'blind_choice_handler', minh = not run_info and 10 or nil, ref_table = { deck = nil, run_info = run_info }, r = 0.1, padding = 0.05 },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = "cm", colour = mix_colours(G.C.BLACK, G.C.L_BLACK, 0.5), r = 0.1, outline = 1, outline_colour = G.C.L_BLACK },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = "cm", padding = 0.2 },
                            nodes = {
                                not run_info and
                                {
                                    n = G.UIT.R,
                                    config = { id = 'select_blind_button', align = "cm", ref_table = blind_choice.config, colour = disabled and G.C.UI.BACKGROUND_INACTIVE or G.C.ORANGE, minh = 0.6, minw = 2.7, padding = 0.07, r = 0.1, shadow = true, hover = true, one_press = true, button = 'select_blind' },
                                    nodes = {
                                        { n = G.UIT.T, config = { ref_table = G.GAME.round_resets.loc_blind_states, ref_value = type, scale = 0.45, colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.UI.TEXT_LIGHT, shadow = not disabled } }
                                    }
                                } or
                                {
                                    n = G.UIT.R,
                                    config = { id = 'select_blind_button', align = "cm", ref_table = blind_choice.config, colour = run_info_colour, minh = 0.6, minw = 2.7, padding = 0.07, r = 0.1, emboss = 0.08 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = localize(blind_state, 'blind_states'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true } }
                                    }
                                }
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { id = 'blind_name', align = "cm", padding = 0.07 },
                            nodes = {
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm", r = 0.1, outline = 1, outline_colour = blind_col, colour = darken(blind_col, 0.3), minw = 2.9, emboss = 0.1, padding = 0.07, line_emboss = 1 },
                                    nodes = {
                                        { n = G.UIT.O, config = { object = DynaText({ string = loc_name, colours = { disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE }, shadow = not disabled, float = not disabled, y_offset = -4, scale = 0.45, maxw = 2.8 }) } },
                                    }
                                },
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = "cm", padding = 0.05 },
                            nodes = {
                                {
                                    n = G.UIT.R,
                                    config = { id = 'blind_desc', align = "cm", padding = 0.05 },
                                    nodes = {
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm" },
                                            nodes = {
                                                {
                                                    n = G.UIT.R,
                                                    config = { align = "cm", minh = 1.5 },
                                                    nodes = {
                                                        { n = G.UIT.O, config = { object = blind_choice.animation } },
                                                    }
                                                },
                                                text_table[1] and
                                                {
                                                    n = G.UIT.R,
                                                    config = { align = "cm", minh = 0.7, padding = 0.05, minw = 2.9 },
                                                    nodes = {
                                                        text_table[1] and {
                                                            n = G.UIT.R,
                                                            config = { align = "cm", maxw = 2.8 },
                                                            nodes = {
                                                                { n = G.UIT.T, config = { id = blind_choice.config.key, ref_table = { val = '' }, ref_value = 'val', scale = 0.32, colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE, shadow = not disabled, func = 'HUD_blind_debuff_prefix' } },
                                                                { n = G.UIT.T, config = { text = text_table[1] or '-', scale = 0.32, colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE, shadow = not disabled } }
                                                            }
                                                        } or nil,
                                                        text_table[2] and {
                                                            n = G.UIT.R,
                                                            config = { align = "cm", maxw = 2.8 },
                                                            nodes = {
                                                                { n = G.UIT.T, config = { text = text_table[2] or '-', scale = 0.32, colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE, shadow = not disabled } }
                                                            }
                                                        } or nil,
                                                    }
                                                } or nil,
                                            }
                                        },
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm", r = 0.1, padding = 0.05, minw = 3.1, colour = G.C.BLACK, emboss = 0.05 },
                                            nodes = {
                                                {
                                                    n = G.UIT.R,
                                                    config = { align = "cm", maxw = 3 },
                                                    nodes = {
                                                        { n = G.UIT.T, config = { text = localize('ph_blind_score_at_least'), scale = 0.3, colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE, shadow = not disabled } }
                                                    }
                                                },
                                                {
                                                    n = G.UIT.R,
                                                    config = { align = "cm", minh = 0.6 },
                                                    nodes = {
                                                        { n = G.UIT.O, config = { w = 0.5, h = 0.5, colour = G.C.BLUE, object = stake_sprite, hover = true, can_collide = false } },
                                                        { n = G.UIT.B, config = { h = 0.1, w = 0.1 } },
                                                        { n = G.UIT.T, config = { text = number_format(blind_amt), scale = score_number_scale(0.9, blind_amt), colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.RED, shadow = not disabled } }
                                                    }
                                                },
                                                _reward and {
                                                    n = G.UIT.R,
                                                    config = { align = "cm" },
                                                    nodes = {
                                                        { n = G.UIT.T, config = { text = localize('ph_blind_reward'), scale = 0.35, colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE, shadow = not disabled } },
                                                        { n = G.UIT.T, config = { text = string.rep(localize("$"), blind_choice.config.dollars) .. '+', scale = 0.35, colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.MONEY, shadow = not disabled } }
                                                    }
                                                } or nil,
                                            }
                                        },
                                    }
                                },
                            }
                        },
                    }
                },
                {
                    n = G.UIT.R,
                    config = { id = 'blind_extras', align = "cm" },
                    nodes = {
                        extras,
                    }
                }
    
            }
        }
        return t
    end

    G.FUNCS.draw_from_deck_to_hand = function(e)
        if not (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and
            G.hand.config.card_limit <= 0 and #G.hand.cards == 0 then 
            G.STATE = G.STATES.GAME_OVER; G.STATE_COMPLETE = false 
            return true
        end
    
        local hand_space = e or (math.min(#G.deck.cards, G.hand.config.card_limit - #G.hand.cards))
        if (G.GAME.blind.name == 'The Jaw') and
        not G.GAME.blind.disabled and
        (G.GAME.current_round.hands_played > 0 or
        G.GAME.current_round.discards_used > 0) then
            if ((G.GAME.dollars - G.GAME.bankrupt_at) < hand_space) then
                hand_space = (G.GAME.dollars - G.GAME.bankrupt_at)
                if ((G.GAME.dollars - G.GAME.bankrupt_at) ~= 0) then
                    ease_dollars(G.GAME.bankrupt_at-G.GAME.dollars)
                    delay(0.1)
                end
            else
                if (hand_space ~= 0) then
                    ease_dollars(-hand_space)
                    delay(0.1)
                end
            end
            if not (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and
                (hand_space <= 0) and (#G.hand.cards == 0) then 
                G.STATE = G.STATES.GAME_OVER; G.STATE_COMPLETE = false 
                return true
            end
        end
        if G.GAME.blind.name == 'The Serpent' and
            not G.GAME.blind.disabled and
            (G.GAME.current_round.hands_played > 0 or
            G.GAME.current_round.discards_used > 0) then
                hand_space = math.min(#G.deck.cards, 3)
        end
        delay(0.3)
        for i=1, hand_space do --draw cards from deckL
            if G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK then 
                draw_card(G.deck,G.hand, i*100/hand_space,'up', true)
            else
                draw_card(G.deck,G.hand, i*100/hand_space,'up', true)
            end
        end
    end

    local old_discard_cards_from_highlighted = G.FUNCS.discard_cards_from_highlighted
    G.FUNCS.discard_cards_from_highlighted = function(e, hook)
        if G.GAME.blind and (G.GAME.blind.name == "The Sink") and not G.GAME.blind.disabled then
            local hands = evaluate_poker_hand(G.hand.highlighted)
            if next(hands["Flush"]) then
                G.E_MANAGER:add_event(Event({trigger = 'immediate',func = function()
                    G.GAME.blind:disable()
                    return true
                end}))
            end
        end
        old_discard_cards_from_highlighted(e, hook)
    end


    G.localization.misc.challenge_names["c_very_cruel"] = "Very Cruel"
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
        
    G.localization.misc.v_text.ch_c_cruel_blinds = {"All blinds past ante {C:attention}1{} are {C:attention}cruel blinds{}."}
    init_localization()
end

function Blind:init(X, Y, W, H)
    Moveable.init(self,X, Y, W, H)

    self.children = {}
    self.config = {}
    self.tilt_var = {mx = 0, my = 0, amt = 0}
    self.ambient_tilt = 0.3
    self.chips = 0
    self.zoom = true
    self.states.collide.can = true
    self.colour = copy_table(G.C.BLACK)
    self.dark_colour = darken(self.colour, 0.2)
    self.children.animatedSprite = AnimatedSprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ANIMATION_ATLAS['blind_chips'], G.P_BLINDS.bl_small.pos)
    self.children.animatedSprite.states = self.states
    self.children.animatedSprite.states.visible = false
    self.children.animatedSprite.states.drag.can = true
    self.states.collide.can = true
    self.states.drag.can = true
    self.loc_debuff_lines = {'',''}
    self.config.blinds = {}

    self.shadow_height = 0

    if getmetatable(self) == Blind then 
        table.insert(G.I.CARD, self)
    end
end

local old_debuff_card = Blind.debuff_card
function Blind:debuff_card(card, from_blind)
    if (self.name == 'The Day') and (card.area ~= G.jokers) and (card:is_suit("Clubs", true) or card:is_suit("Spades", true)) and not self.disabled then
        card:set_debuff(true)
        return
    end
    if (self.name == 'The Night') and (card.area ~= G.jokers) and (card:is_suit("Hearts", true) or card:is_suit("Diamonds", true)) and not self.disabled then
        card:set_debuff(true)
        return
    end
    if (self.name == 'Common Muck') and (card.area == G.jokers) and not self.disabled and (card.config.center.rarity > 2) then
        card:set_debuff(true)
        return
    end
    if (self.name == 'Daring Group') and ((self.config.blinds[1] == 'Crimson Heart') or (self.config.blinds[2] == 'Crimson Heart') or (self.config.blinds[3] == 'Crimson Heart')) and not self.disabled and card.area == G.jokers then 
        return
    end
    if self.name == 'Daring Group' and ((self.config.blinds[1] == 'Verdant Leaf') or (self.config.blinds[2] == 'Verdant Leaf') or (self.config.blinds[3] == 'Verdant Leaf')) and (self.config.joker_sold ~= true) and not self.disabled and card.area ~= G.jokers then card:set_debuff(true); return end
    old_debuff_card(self, card, from_blind)
end

local old_press_play = Blind.press_play
function Blind:press_play()
    local value = old_press_play(self)
    if (value ~= nil) then
        return value
    end
    if self.disabled then return end
    if self.name == 'Daring Group' then 
        if G.jokers.cards[1] then
            self.triggered = true
            self.prepped = true
        end
    end
    -- if self.name == 'The Puzzle' then
    --     G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
    --         for i = 1, #G.hand.cards do
    --             if G.hand.cards[i] then 
    --                 local rank = pseudorandom_element({'A', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K'}, pseudoseed('puzzle'))
    --                 local suit = pseudorandom_element({'H', 'D', 'S', 'C'}, pseudoseed('puzzle'))
    --                 local Thecard = suit .. '_' .. rank
    --                 G.E_MANAGER:add_event(Event({func = function() G.hand.cards[i]:set_base(G.P_CARDS[Thecard]);G.hand.cards[i]:juice_up();play_sound('card1', 1); return true end }))
    --                 delay(0.23)
    --             end
    --         end
    --     return true end }))
    --     return true
    -- end
end

local old_load = Blind.load
function Blind:load(blindTable)
    self.config.blinds = blindTable.blinds or {}

    self.config.joker_sold = blindTable.didSell or false
    old_load(self, blindTable)
end

local old_save = Blind.save
function Blind:save()
    local blindTable = old_save(self)
    blindTable.blinds = self.config.blinds
    blindTable.didSell = self.config.joker_sold
    return blindTable
end

local old_disable = Blind.disable
function Blind:disable()
    if self.name == 'Daring Group' then
        if (self.config.blinds[1] == 'Cerulean Bell') or (self.config.blinds[2] == 'Cerulean Bell') or (self.config.blinds[3] == 'Cerulean Bell') then
            for k, v in ipairs(G.playing_cards) do
                v.ability.forced_selection = nil
            end
        end
        self.chips = get_blind_amount(G.GAME.round_resets.ante)*self.mult*G.GAME.starting_params.ante_scaling
        self.chip_text = number_format(self.chips)
        self:set_text()
    end
    if (self.name == "The Tide") or (self.name == "The Sword") then
        ease_discard(self.discards_sub)
        ease_hands_played(self.hands_sub)
    end
    if self.name == 'The Shackle' then
        G.hand:change_size(2)
        
        G.FUNCS.draw_from_deck_to_hand(2)
    end
    if self.name == 'The Hurdle' then
        ease_ante(-1)
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante-1
        self.chips = get_blind_amount(G.GAME.round_resets.ante-1)*self.mult*G.GAME.starting_params.ante_scaling
        self.chip_text = number_format(self.chips)
        self:set_text()
    end
    if self.name == 'The Day' or self.name == 'The Night' or self.name == 'The Mind' then 
        for i = 1, #G.hand.cards do
            if G.hand.cards[i].facing == 'back' then
                G.hand.cards[i]:flip()
            end
        end
        for k, v in pairs(G.playing_cards) do
            v.ability.wheel_flipped = nil
        end
    end
    if self.name == 'The Collapse' then
        self.chips = get_blind_amount(G.GAME.round_resets.ante)*self.mult*G.GAME.starting_params.ante_scaling
        self.chip_text = number_format(self.chips)
        self:set_text()
    end
    old_disable(self)
end

local old_modify_hand = Blind.modify_hand
function Blind:modify_hand(cards, poker_hands, text, mult, hand_chips)
    if self.disabled then return mult, hand_chips, false end
    mult, hand_chips, isBlind = old_modify_hand(self, cards, poker_hands, text, mult, hand_chips)
    if (isBlind) then
        return mult, hand_chips, isBlind
    end
    -- if (self.name == "The Steel") then
    --     self.triggered = true
    --     return -mult, -hand_chips, true
    -- end
    return mult, hand_chips, false
end

local old_evaluate_poker_hand = evaluate_poker_hand
function evaluate_poker_hand(hand)

    local results = old_evaluate_poker_hand(hand)
    if G.GAME.blind and (G.GAME.blind.name == "The Steal") and not G.GAME.blind.disabled then
        if G.GAME.current_round.most_played_poker_hand == "High Card" then
            results["Pair"] = {}
        else
            results[G.GAME.current_round.most_played_poker_hand] = {}
        end
    end
    return results
end

local old_debuff_hand =  Blind.debuff_hand
function Blind:debuff_hand(cards, hand, handname, check)
    if self.disabled then return end
    local value = old_debuff_hand(self, cards, hand, handname, check)
    if (value == true) then
        return true
    end
    if self.name == "The Sink" then
        self.triggered = true
        return true
    end
    if self.name == 'The Collapse' then
        self.triggered = false
        if not check then
            self.triggered = true
            local count = G.GAME.hands[handname].played - 1
            if (count > 0) then
                self.chips = math.floor(self.chips * (1 + (0.04 * count)))
                self.chip_text = number_format(self.chips)
                self:set_text()
                G.hand_text_area.blind_chips:juice_up()
            end
        end
    end
    if self.name == 'The Reach' then
        self.triggered = false
        if not check then
            local count = math.min(G.GAME.hands[handname].level - 1, math.floor(G.GAME.hands[handname].level / 2))
            if (count > 0) then
                if not check then
                    self.triggered = true
                    level_up_hand(self.children.animatedSprite, handname, nil, -count)
                    self:wiggle()
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
                            level_up_hand(self.children.animatedSprite, i, true, j)
                            update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(i, 'poker_hands'),chips = G.GAME.hands[i].chips, mult = G.GAME.hands[i].mult, level=G.GAME.hands[i].level})
                            delay(0.35)
                            self:wiggle()
                        end
                    end
                    update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(handname, 'poker_hands'),chips = G.GAME.hands[handname].chips, mult = G.GAME.hands[handname].mult, level=G.GAME.hands[handname].level})
                end
            end
        end
    end
end

function get_new_boss()
    G.GAME.perscribed_bosses = G.GAME.perscribed_bosses or {
    }
    if G.GAME.perscribed_bosses and G.GAME.perscribed_bosses[G.GAME.round_resets.ante] then 
        local ret_boss = G.GAME.perscribed_bosses[G.GAME.round_resets.ante] 
        G.GAME.perscribed_bosses[G.GAME.round_resets.ante] = nil
        G.GAME.bosses_used[ret_boss] = G.GAME.bosses_used[ret_boss] + 1
        return ret_boss
    end
    if G.FORCE_BOSS then return G.FORCE_BOSS end
    
    local eligible_bosses = {}
    for k, v in pairs(G.P_BLINDS) do
        if not v.boss then

        elseif G.GAME.modifiers["cruel_blinds"] and (G.GAME.round_resets.ante >= 2) and (v.boss.hardcore ~= true) then


        elseif v.boss.no_penultimate and (G.GAME.round_resets.ante == G.GAME.win_ante - 1) then

        elseif not v.boss.showdown and (v.boss.min <= math.max(1, G.GAME.round_resets.ante) and ((math.max(1, G.GAME.round_resets.ante))%G.GAME.win_ante ~= 0 or G.GAME.round_resets.ante < 2)) then
            eligible_bosses[k] = true
        elseif v.boss.showdown and (G.GAME.round_resets.ante)%G.GAME.win_ante == 0 and G.GAME.round_resets.ante >= 2 then
            eligible_bosses[k] = true
        end
    end
    for k, v in pairs(G.GAME.banned_keys) do
        if eligible_bosses[k] then eligible_bosses[k] = nil end
    end

    local min_use = 100
    for k, v in pairs(G.GAME.bosses_used) do
        if eligible_bosses[k] then
            eligible_bosses[k] = v
            if eligible_bosses[k] <= min_use then 
                min_use = eligible_bosses[k]
            end
        end
    end
    for k, v in pairs(eligible_bosses) do
        if eligible_bosses[k] then
            if eligible_bosses[k] > min_use then 
                eligible_bosses[k] = nil
            end
        end
    end
    local _, boss = pseudorandom_element(eligible_bosses, pseudoseed('boss'))
    G.GAME.bosses_used[boss] = G.GAME.bosses_used[boss] + 1
    
    return boss
end

----------------------------------------------
------------MOD CODE END----------------------