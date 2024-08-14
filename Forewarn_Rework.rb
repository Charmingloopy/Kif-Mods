BattleHandlers::AbilityOnSwitchIn.add(:FOREWARN,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    @evaded_move = false
    highestPower = 0
    forewarnMoves = []
    battle.eachOtherSideBattler(battler.index) do |b|
      b.eachMove do |m|
        power = m.baseDamage
        power = 160 if ["070"].include?(m.function)    # OHKO
        power = 150 if ["08B"].include?(m.function)    # Eruption
        # Counter, Mirror Coat, Metal Burst
        power = 120 if ["071","072","073"].include?(m.function)
        # Sonic Boom, Dragon Rage, Night Shade, Endeavor, Psywave,
        # Return, Frustration, Crush Grip, Gyro Ball, Hidden Power,
        # Natural Gift, Trump Card, Flail, Grass Knot
        power = 80 if ["06A","06B","06D","06E","06F",
                       "089","08A","08C","08D","090",
                       "096","097","098","09A"].include?(m.function)
        next if power<highestPower
        forewarnMoves = [] if power>highestPower
        forewarnMoves.push(m.name)
        highestPower = power
      end
    end
    if forewarnMoves.length>0
      battle.pbShowAbilitySplash(battler)
      @forewarnMoveName = forewarnMoves[battle.pbRandom(forewarnMoves.length)]
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} was alerted to {2}!",
          battler.pbThis, @forewarnMoveName))
      else
        battle.pbDisplay(_INTL("{1}'s Forewarn alerted it to {2}!",
          battler.pbThis, @forewarnMoveName))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FOREWARN,
  proc { |ability,user,target,move,type,battle|
    next false if move.name != @forewarnMoveName
    next false if @evaded_move == true
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} evaded the attack!",target.pbThis))
    @evaded_move = true
    next true
  }
)