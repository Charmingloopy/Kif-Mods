
LOLPY_FUSEMON_ID_TRAINER = 422
LOLPY_FUSEMON_CHOICE_ID_TRAINER = 423
LOLPY_FUSEMON_ID = 424
LOLPY_FUSEMON_CHOICE_ID = 425

def get_randomized_bst_hash(poke_list, bst_range,show_progress=true)
        bst_hash = Hash.new
        for i in 1..NB_POKEMON - 1
          show_shuffle_progress(i) if show_progress
          baseStats = getBaseStatsFormattedForRandomizer(i)
          statsTotal = getStatsTotal(baseStats)
      
          targetStats_max = statsTotal + bst_range
          targetStats_min = statsTotal - bst_range
          max_bst_allowed=targetStats_max
          min_bst_allowed=targetStats_min
          #if a match, add to hash, remove from array, and cycle to next poke in dex
          playShuffleSE(i)
          random_poke = poke_list.sample
          random_poke_bst=getStatsTotal(getBaseStatsFormattedForRandomizer(random_poke))
          j=0
          while(random_poke_bst <= min_bst_allowed || random_poke_bst >= max_bst_allowed)
            random_poke = poke_list.sample
            random_poke_bst=getStatsTotal(getBaseStatsFormattedForRandomizer(random_poke))
            fusepoke_id = $game_variables[LOLPY_FUSEMON_ID]
            if fusepoke_id >= 1
                if $game_variables[LOLPY_FUSEMON_CHOICE_ID] == 2
                 random_poke = getFusedPokemonIdFromDexNum(random_poke, fusepoke_id)
                 end
                if $game_variables[LOLPY_FUSEMON_CHOICE_ID] == 1
                 random_poke = getFusedPokemonIdFromDexNum(fusepoke_id,random_poke)
                 end
                if $game_variables[LOLPY_FUSEMON_CHOICE_ID] == 0
                    if rand(1) < 0.5 then

                      random_poke = getFusedPokemonIdFromDexNum(random_poke, fusepoke_id)
                    else
                      random_poke = getFusedPokemonIdFromDexNum(fusepoke_id,random_poke)
                      end
                end

            j+=1
            if j % 5 ==0  #to avoid infinite loops if can't find anything
              min_bst_allowed-=1
              max_bst_allowed+=1
              end
            end
          end
          bst_hash[i] = random_poke
        end
        return bst_hash
      end






class RandomizerTrainerOptionsScene < PokemonOption_Scene
 def pbGetOptions(inloadscreen = false)
        options = []
        if !$game_switches[SWITCH_DURING_INTRO]
          options << SliderOption.new(_INTL("Randomness degree"), 25, 500, 5,
                                      proc { $game_variables[VAR_RANDOMIZER_TRAINER_BST] },
                                      proc { |value|
                                        $game_variables[VAR_RANDOMIZER_TRAINER_BST] = value
                                      })
        end
        options << EnumOption.new(_INTL("Custom Sprites only"), [_INTL("On"), _INTL("Off")],
                                  proc { $game_switches[RANDOM_TEAMS_CUSTOM_SPRITES] ? 0 : 1 },
                                  proc { |value|
                                    $game_switches[RANDOM_TEAMS_CUSTOM_SPRITES] = value == 0
                                  },
                                  "Use only Pokémon that have custom sprites in trainer teams"
       )
    #    options << SliderOption.new(_INTL("Fusing Trainer pokemon with",), 0, 470, 1,
   #     proc { $game_variables[LOLPY_FUSEMON_ID_TRAINER] },
     #   proc { |value|
     #   $game_variables[LOLPY_FUSEMON_ID_TRAINER]=value
     #    if value > 0
     #      @newpokes = Pokemon.new($game_variables[LOLPY_FUSEMON_ID_TRAINER],10).name
     #    else
    #      @newpokes = "None"
       #  end
          
       # }, "fuse all trainer pokemon with the pokemon that has this id, 0 disables this."
       # )
        #options << EnumOption.new(_INTL("What part to replace",), [_INTL("Random"), _INTL("Body"),_INTL("Head")],
        #proc { $game_variables[LOLPY_FUSEMON_CHOICE_ID_TRAINER] },
        #proc { |value|
        #$game_variables[LOLPY_FUSEMON_CHOICE_ID_TRAINER]=value
        #puts value
     
       # }, "replace either the body or head with this pokemon."
       # )
        return options
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
      
      @newpokes = "None"
      options << SliderOption.new(_INTL("Fusing Wild pokemon with",), 0, 470, 1,
                                      proc { $game_variables[LOLPY_FUSEMON_ID] },
                                      proc { |value|
                                      $game_variables[LOLPY_FUSEMON_ID]=value
                                       if value > 0
                                         @newpokes = Pokemon.new($game_variables[LOLPY_FUSEMON_ID],10).name
                                       else
                                        @newpokes = "None"
                                       end
                                        
                                      }, "fuse all wild pokemon with the pokemon that has this id, 0 disables this."
                                      )
      options << EnumOption.new(_INTL("What part to replace",), [_INTL("Random"), _INTL("Body"),_INTL("Head")],
      proc { $game_variables[LOLPY_FUSEMON_CHOICE_ID] },
      proc { |value|
      $game_variables[LOLPY_FUSEMON_CHOICE_ID]=value
      puts value
   
      }, "replace either the body or head with this pokemon."
      )
      return options
    end
end

#def Kernel.pbShuffleTrainers(bst_range = 50, customsOnly = false, customsList = nil)
#    bst_range = pbGet(VAR_RANDOMIZER_TRAINER_BST)
  
 #   if customsOnly && customsList == nil
#      customsOnly = false
  #  end
 #   randomTrainersHash = Hash.new
  #  trainers_data = GameData::Trainer.list_all
  #  trainers_array = trainers_data
  #  trainers_data.each do |key, value|
   #   trainer = trainers_data[key]
    #  i = 0
    #  new_party = []
      #for poke in trainer.pokemon
     #   old_poke = GameData::Species.get(poke[:species]).id_number
     #   new_poke = customsOnly ? getNewCustomSpecies(old_poke, customsList, bst_range) : getNewSpecies(old_poke, bst_range)
      #  fusepoke_id = $game_variables[LOLPY_FUSEMON_ID_TRAINER]
    #    if fusepoke_id >= 1
           # if $game_variables[LOLPY_FUSEMON_CHOICE_ID_TRAINER] == 2
     #        new_poke = getFusedPokemonIdFromDexNum(getNewSpecies(old_poke, bst_range), fusepoke_head_id)
            # end
     #       if $game_variables[LOLPY_FUSEMON_CHOICE_ID_TRAINER] == 1
          #   new_poke = getFusedPokemonIdFromDexNum(fusepoke_body_id,getNewSpecies(old_poke, bst_range))
         #    end
     #       if $game_variables[LOLPY_FUSEMON_CHOICE_ID_TRAINER] == 0
        #        if rand(1) < 0.5 then
#
          #        new_poke = getFusedPokemonIdFromDexNum(getNewSpecies(old_poke, bst_range), fusepoke_id)
     #           else
         #         new_poke = getFusedPokemonIdFromDexNum(fusepoke_id,getNewSpecies(old_poke, bst_range))
   #               end
       #         end
  #      new_party << new_poke
     #    end
      #randomTrainersHash[trainer.id] = new_party
      #playShuffleSE(i)
      #i += 1
      #if i % 2 == 0
        #n = (i.to_f / trainers_array.length) * 100
       # Kernel.pbMessageNoSound(_INTL("\\ts[]Shuffling trainers...\\n {1}%\\^", sprintf('%.2f', n), PBSpecies.maxValue))
    #  end
   # end
  #  $PokemonGlobal.randomTrainersHash = randomTrainersHash
 # end
#end
