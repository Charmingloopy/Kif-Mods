SWITCH_LOLPY_SHUFFLE = 420
LOLPY_FUSEMON_TYPE = 421
SWITCH_LOLPY_CHALLENGES = 422
LOLPY_FUSEMON_ID_TRAINER = 422
LOLPY_FUSEMON_CHOICE_ID_TRAINER = 423
LOLPY_FUSEMON_ID = 424
LOLPY_FUSEMON_CHOICE_ID = 425
REGULAR_TO_FUSIONS = 953
@lolpy_pokelist = get_pokemon_list(false)
def get_randomized_bst_hash(poke_list, bst_range,show_progress=true,randomize = true)

        bst_hash = Hash.new
        for i in 1..NB_POKEMON - 1
          show_shuffle_progress(i) if show_progress
          baseStats = getBaseStatsFormattedForRandomizer(i)
          statsTotal = getStatsTotal(baseStats)
      
          targetStats_max = statsTotal + bst_range
          targetStats_min = statsTotal - bst_range
          max_bst_allowed=targetStats_max
          min_bst_allowed=targetStats_min
          if randomize == false
           random_poke = i
           end
          #if a match, add to hash, remove from array, && cycle to next poke in dex
          playShuffleSE(i)
          if randomize == true
           random_poke = poke_list.sample
           end
          random_poke_bst=getStatsTotal(getBaseStatsFormattedForRandomizer(random_poke))
          
          j=0
          while(random_poke_bst <= min_bst_allowed || random_poke_bst >= max_bst_allowed)
            if randomize == true
             random_poke = poke_list.sample
             random_poke_bst=getStatsTotal(getBaseStatsFormattedForRandomizer(random_poke))
            else
              random_poke = i
              end
           end
          newpoke = Pokemon.new(i,10)
  fusepoke_choice = $game_variables[LOLPY_FUSEMON_CHOICE_ID]
  fusepoke_id = $game_variables[LOLPY_FUSEMON_ID]
  fusepoke_type = $game_variables[LOLPY_FUSEMON_TYPE]
  fusepoke_choice = $game_variables[LOLPY_FUSEMON_CHOICE_ID]
  fusepoke_id = $game_variables[LOLPY_FUSEMON_ID]
  fusepoke_type = $game_variables[LOLPY_FUSEMON_TYPE]
  if fusepoke_type > 0
    poketype = false
    pokemon_amount = NB_POKEMON - 1

    tries = 0
    max_tries = rand(rand(80...130)...rand(200...pokemon_amount))

    types = [:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,:ROCK,:BUG,:GHOST,:STEEL,:FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,:ICE,:DRAGON,:DARK,:FAIRY]
    selectable_mons = []
    min_mons = 4
    while tries < max_tries && selectable_mons.size < min_mons
      
      
      mon_statsTotal = getStatsTotal( getBaseStatsFormattedForRandomizer(species))
      spec_statsTotal = getStatsTotal( getBaseStatsFormattedForRandomizer(species))
      tries += 1
      puts tries
      mon = tries
      pokes = Pokemon.new(mon,10)
      puts pokes.name
      if fusepoke_choice == 2
        if pokes.type2 == types[fusepoke_type - 1] && mon_statsTotal <= spec_statsTotal * 1.5
          poketype = true
          selectable_mons.push(mon)
          
         end
        end
      if fusepoke_choice == 1
          
          if pokes.type1 == types[fusepoke_type - 1] && mon_statsTotal <= spec_statsTotal * 1.5
            poketype = true
            selectable_mons.push(mon)
            
           end
          end
      if fusepoke_choice == 0
       if pokes.hasType?(types[fusepoke_type - 1]) && mon_statsTotal <= spec_statsTotal * 1.5
         poketype = true
         selectable_mons.push(mon)
         end
       end


      if selectable_mons.size < min_mons && max_tries < pokemon_amount
        min_mons -= 1
        max_tries += 1
      end
    
    if selectable_mons.size > 0
      fusepoke_id = selectable_mons.sample
     if random_poke == fusepoke_id
       selectable_mons.delete(random_poke)
       fusepoke_id = selectable_mons.sample
       end
     end
    puts selectable_mons.inspect
    end
          

  if fusepoke_id >= 1 && !$game_switches[REGULAR_TO_FUSIONS]
    if $game_variables[LOLPY_FUSEMON_CHOICE_ID] == 2 && !isFusion(random_poke)
         random_poke = getFusedPokemonIdFromDexNum(random_poke, fusepoke_id)
         end
     if $game_variables[LOLPY_FUSEMON_CHOICE_ID] == 1 && !isFusion(random_poke)
         random_poke = getFusedPokemonIdFromDexNum(fusepoke_id,random_poke)
         end
    if $game_variables[LOLPY_FUSEMON_CHOICE_ID] == 0 && !isFusion(random_poke)
          if rand(1) < 0.5 then

             random_poke = getFusedPokemonIdFromDexNum(random_poke, fusepoke_id)
          else
            random_poke = getFusedPokemonIdFromDexNum(fusepoke_id,random_poke)
            end
          end
    end

  j+=1
  if j % 5 ==0  #to avoid infinite loops if can't find anything
      min_bst_allowed-=1
      max_bst_allowed+=1
      end
  end
  bst_hash[i] = random_poke
 end
return bst_hash
end






class Loopy_Chalmod_OptionsScene < PokemonOption_Scene
  def pbGetOptions(inloadscreen = false)
    options = [
      SliderOption.new(_INTL("Type challenge",), 0, 18, 1,
      proc { $game_variables[LOLPY_FUSEMON_TYPE] },
      proc { |value|
      $game_variables[LOLPY_FUSEMON_TYPE]=value
      
      
    }, "fuse wild pokemon with a pokemon that has this type."
    ),
      SliderOption.new(_INTL("Id challenge",), 0, 470, 1,
        proc { $game_variables[LOLPY_FUSEMON_ID] },
        proc { |value|
        $game_variables[LOLPY_FUSEMON_ID]=value
        
        
      }, "fuse wild pokemon with the id."
      ),

      EnumOption.new(_INTL("What part to replace",), [_INTL("Random"), _INTL("Body"),_INTL("Head")],
        proc { $game_variables[LOLPY_FUSEMON_CHOICE_ID] },
        proc { |value|
        $game_variables[LOLPY_FUSEMON_CHOICE_ID]=value
        }, "replace either the body or head with this pokemon."
      ),

    ]
    return options
   end
 end
class RandomizerOptionsScene < PokemonOption_Scene
  def initialize
    super
    @openTrainerOptions = false
    @openWildOptions = false
    @openGymOptions = false
    @openItemOptions = false
    $game_switches[SWITCH_RANDOMIZED_AT_LEAST_ONCE] = true
  end

  def getDefaultDescription
    return _INTL("Set the randomizer settings")
  end

  def pbStartScene(inloadscreen = false)
    super
    @changedColor = true
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Randomizer settings"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"].text = getDefaultDescription
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbGetOptions(inloadscreen = false)
    options = [
      EnumOption.new(_INTL("Pokémon"), [_INTL("On"), _INTL("Off")],
                     proc {
                       $game_switches[SWITCH_RANDOM_WILD] ? 0 : 1
                     },
                     proc { |value|
                       if !$game_switches[SWITCH_RANDOM_WILD] && value == 0
                         @openWildOptions = true
                         openWildPokemonOptionsMenu()
                       end
                       $game_switches[SWITCH_RANDOM_WILD] = value == 0
                     }, "Select the randomizer options for Pokémon"
      ),
      EnumOption.new(_INTL("NPC Trainers"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_TRAINERS] ? 0 : 1 },
                     proc { |value|
                       if !$game_switches[SWITCH_RANDOM_TRAINERS] && value == 0
                         @openTrainerOptions = true
                         openTrainerOptionsMenu()
                       end
                       $game_switches[SWITCH_RANDOM_TRAINERS] = value == 0
                     }, "Select the randomizer options for trainers"
      ),

      EnumOption.new(_INTL("Gym trainers"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOMIZE_GYMS_SEPARATELY] ? 0 : 1 },
                     proc { |value|
                       if !$game_switches[SWITCH_RANDOMIZE_GYMS_SEPARATELY] && value == 0
                         @openGymOptions = true
                         openGymOptionsMenu()
                       end
                       $game_switches[SWITCH_RANDOMIZE_GYMS_SEPARATELY] = value == 0
                     }, "Limit gym trainers to a single type"
      ),

      EnumOption.new(_INTL("Items"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_ITEMS_GENERAL] ? 0 : 1 },
                     proc { |value|
                       if !$game_switches[SWITCH_RANDOM_ITEMS_GENERAL] && value == 0
                         @openItemOptions = true
                         openItemOptionsMenu()
                       end
                       $game_switches[SWITCH_RANDOM_ITEMS_GENERAL] = value == 0
                     }, "Select the randomizer options for items"
      ),
      EnumOption.new(_INTL("Loopy's challenges"), [_INTL("On"), _INTL("Off")],
      proc { $game_switches[SWITCH_LOLPY_CHALLENGES] ? 0 : 1 },
      proc { |value|
        if !$game_switches[SWITCH_LOLPY_CHALLENGES] && value == 0
         if !$game_switches[SWITCH_LOLPY_SHUFFLE]
           @lolpy_pokelist = get_pokemon_list(false)
           @lolpy_pokelist.shuffle!
           $game_switches[SWITCH_LOLPY_SHUFFLE] = true
         end

          @openLoopchalOptions = true
          openLoopChallengeOptionsMenu()
        end
        $game_switches[SWITCH_LOLPY_CHALLENGES] = value == 0
      }, "Options for loopy's challenge mods"
      ),
     ]
     return options
     end
  def openLoopChallengeOptionsMenu()
    return if !@openLoopchalOptions
    pbFadeOutIn {
      scene = Loopy_Chalmod_OptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @openLoopchalOptions = false
  end
end

class RandomizerWildPokemonOptionsScene < PokemonOption_Scene
    def pbGetOptions(inloadscreen = false)
      options = []
      if !$game_switches[SWITCH_DURING_INTRO]
        options << SliderOption.new(_INTL("Randomness degree"), 25, 500, 5,
                                    proc { $game_variables[VAR_RANDOMIZER_WILD_POKE_BST] },
                                    proc { |value|
                                      $game_variables[VAR_RANDOMIZER_WILD_POKE_BST] = value
                                    })
      end
  
      options << EnumOption.new(_INTL("Type"), [_INTL("Global"), _INTL("Area")],
                                proc {
                                  if $game_switches[RANDOM_WILD_AREA]
                                    1
                                  else
                                    0
                                  end
                                },
                                proc { |value|
                                  if value == 0
                                    $game_switches[RANDOM_WILD_GLOBAL] = true
                                    $game_switches[RANDOM_WILD_AREA] = false
                                  else
                                    value == 1
                                    $game_switches[RANDOM_WILD_GLOBAL] = false
                                    $game_switches[RANDOM_WILD_AREA] = true
                                  end
                                },
                                [
                                  "Randomizes Pokémon using a one-to-one mapping of the Pokedex",
                                  "Randomizes the encounters in each route individually"
                                ]
      )
      options << EnumOption.new(_INTL("Custom sprites only"), [_INTL("On"), _INTL("Off")],
                                proc { $game_switches[SWITCH_RANDOM_WILD_ONLY_CUSTOMS] ? 0 : 1 },
                                proc { |value|
                                  $game_switches[SWITCH_RANDOM_WILD_ONLY_CUSTOMS] = value == 0
                                }, "['Fuse everything' & starters] Include only  Pokémon with a custom sprite."
      )
  
      options << EnumOption.new(_INTL("Starters"), [_INTL("On"), _INTL("Off")],
                                proc { $game_switches[SWITCH_RANDOM_STARTERS] ? 0 : 1 },
                                proc { |value|
                                  $game_switches[SWITCH_RANDOM_STARTERS] = value == 0
                                }, "Randomize the selection of starters to choose from at the start of the game"
      )
      options << EnumOption.new(_INTL("Static encounters"), [_INTL("On"), _INTL("Off")],
                                proc { $game_switches[RANDOM_STATIC] ? 0 : 1 },
                                proc { |value|
                                  $game_switches[RANDOM_STATIC] = value == 0
                                },
                                "Randomize Pokémon that appear in the overworld (including legendaries)"
      )
  
      options << EnumOption.new(_INTL("Gift Pokémon"), [_INTL("On"), _INTL("Off")],
                                proc { $game_switches[GIFT_POKEMON] ? 0 : 1 },
                                proc { |value|
                                  $game_switches[GIFT_POKEMON] = value == 0
                                }, "Randomize Pokémon that are gifted to the player"
      )
  
      options << EnumOption.new(_INTL("Fuse everything"), [_INTL("On"), _INTL("Off")],
                                proc { $game_switches[REGULAR_TO_FUSIONS] ? 0 : 1 },
                                proc { |value|
                                  $game_switches[REGULAR_TO_FUSIONS] = value == 0
                                }, "Include fused Pokémon in the randomize pool for wild Pokémon"
      )
      
      return options
    end
end




def pbGenerateWildPokemon(species,level,isRoamer=false)
  if !$game_switches[SWITCH_LOLPY_SHUFFLE]
    @lolpy_pokelist = get_pokemon_list(false)
    @lolpy_pokelist.shuffle!
    $game_switches[SWITCH_LOLPY_SHUFFLE] = true
  end
  newpoke = Pokemon.new(species,10)
  poke_list = @lolpy_pokelist
  puts poke_list.inspect
  fusepoke_choice = $game_variables[LOLPY_FUSEMON_CHOICE_ID]
  fusepoke_id = $game_variables[LOLPY_FUSEMON_ID]
  fusepoke_type = $game_variables[LOLPY_FUSEMON_TYPE]
  if fusepoke_type > 0
    poketype = false
    pokemon_amount = NB_POKEMON - 1
    bst_multi = 1

    tries = 0
    #max_tries = rand(rand(150...180)...rand(181...pokemon_amount))
    max_tries = pokemon_amount

    types = [:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,:ROCK,:BUG,:GHOST,:STEEL,:FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,:ICE,:DRAGON,:DARK,:FAIRY]
    selectable_mons = []
    min_mons = rand(2,4)
    if fusepoke_type == 1
      min_mons = rand(4,6)
    end
    if fusepoke_type == 3
      min_mons = rand(4,6)
    end
    if fusepoke_type == 7
      min_mons = rand(4,6)
    end
    if fusepoke_type == 11
      min_mons = rand(4,6)
    end
    while tries < max_tries && selectable_mons.size < min_mons
      
      
      mon_statsTotal = getStatsTotal( getBaseStatsFormattedForRandomizer(species))
      spec_statsTotal = getStatsTotal( getBaseStatsFormattedForRandomizer(species))
      
      puts tries
      mon = poke_list[tries]
      tries += 1
      pokes = Pokemon.new(mon,10)
      puts pokes.name
      if fusepoke_choice == 2
        if pokes.type2 == types[fusepoke_type - 1] && mon_statsTotal <= spec_statsTotal * bst_multi
          poketype = true
          selectable_mons.push(mon)
          end
        end
      if fusepoke_choice == 1 
          if pokes.type1 == types[fusepoke_type - 1] && mon_statsTotal <= spec_statsTotal * bst_multi
            poketype = true
            selectable_mons.push(mon)
            end
          end
      if fusepoke_choice == 0
       if pokes.hasType?(types[fusepoke_type - 1]) && mon_statsTotal <= spec_statsTotal * bst_multi
         poketype = true
         selectable_mons.push(mon)
         end
       end


      if selectable_mons.size < min_mons && selectable_mons.size > 0  
        bst_multi += 0.01   
        min_mons -= 1
        end
      end
    
    if selectable_mons.size > 0
      fusepoke_id = selectable_mons.sample
     if species == fusepoke_id
       selectable_mons.delete(species)
       fusepoke_id = selectable_mons.sample
       end
     end
    puts selectable_mons.inspect
    end
  if fusepoke_id >= 1 && !$game_switches[REGULAR_TO_FUSIONS]
      if $game_variables[LOLPY_FUSEMON_CHOICE_ID] == 2 && !isFusion(getDexNumberForSpecies(species))
       species = getSpeciesIdForFusion(getDexNumberForSpecies(species), fusepoke_id)
       end
      if $game_variables[LOLPY_FUSEMON_CHOICE_ID] == 1 && !isFusion(getDexNumberForSpecies(species))
       species = getSpeciesIdForFusion(fusepoke_id, getDexNumberForSpecies(species))
       end
      if $game_variables[LOLPY_FUSEMON_CHOICE_ID] == 0 && !isFusion(getDexNumberForSpecies(species))
          if rand(1) < 0.5 then

           species = getSpeciesIdForFusion(getDexNumberForSpecies(species), fusepoke_id)
          else
           species = getSpeciesIdForFusion(fusepoke_id,getDexNumberForSpecies(species))
            end
        end
    end


  genwildpoke = Pokemon.new(species,level)
  # Give the wild Pokémon a held item
  items = genwildpoke.wildHoldItems
  first_pkmn = $Trainer.first_pokemon
  chances = [50,5,1]
  chances = [60,20,5] if first_pkmn && first_pkmn.hasAbility?(:COMPOUNDEYES)
  itemrnd = rand(100)
  if (items[0]==items[1] && items[1]==items[2]) || itemrnd<chances[0]
    genwildpoke.item = items[0]
  elsif itemrnd<(chances[0]+chances[1])
    genwildpoke.item = items[1]
  elsif itemrnd<(chances[0]+chances[1]+chances[2])
    genwildpoke.item = items[2]
  end
  # Shiny Charm makes shiny Pokémon more likely to generate
  if GameData::Item.exists?(:SHINYCHARM) && $PokemonBag.pbHasItem?(:SHINYCHARM)
    2.times do   # 3 times as likely
      break if genwildpoke.shiny?
      genwildpoke.personalID = rand(2**16) | rand(2**16) << 16
    end
  end
  # Give Pokérus
  genwildpoke.givePokerus if rand(65536) < Settings::POKERUS_CHANCE
  # Change wild Pokémon's gender/nature depending on the lead party Pokémon's
  # ability
  if first_pkmn
    if first_pkmn.hasAbility?(:CUTECHARM) && !genwildpoke.singleGendered?
      if first_pkmn.male?
        (rand(3)<2) ? genwildpoke.makeFemale : genwildpoke.makeMale
      elsif first_pkmn.female?
        (rand(3)<2) ? genwildpoke.makeMale : genwildpoke.makeFemale
      end
    elsif first_pkmn.hasAbility?(:SYNCHRONIZE)
      genwildpoke.nature = first_pkmn.nature if !isRoamer && rand(100)<50
    end
  end
  # Trigger events that may alter the generated Pokémon further
  Events.onWildPokemonCreate.trigger(nil,genwildpoke)
  return genwildpoke
end