#===============================================================================
# Power is chosen at random. Power is doubled if the target is using Dig. Hits
# some semi-invulnerable targets. (Magnitude)
#===============================================================================
class PokeBattle_Move_095 < PokeBattle_Move
    def hitsDiggingTargets?; return true; end
  
    def pbOnStartUse(user,targets)
      baseDmg = [10,30,50,70,90,110,150]
      magnitudes = [
         4,
         5,5,
         6,6,6,6,
         7,7,7,7,7,7,
         8,8,8,8,
         9,9,
         10
      ]
      magni = magnitudes[@battle.pbRandom(magnitudes.length)]
      @magnitudeDmg = baseDmg[magni-4]
      @battle.pbDisplay(_INTL("Magnitude {1}!",magni))
      @magnisize = magni
    end
    
    def pbEffectAgainstTarget(user, target)
     if @magnisize >= 8 then
        target.pbOwnSide.effects[PBEffects::StealthRock] = true
        @battle.pbDisplay(_INTL("The size {1} magnitude caused stealth rocks to land on to the field!",@magnisize))
      end
     end
 
    def pbBaseDamage(baseDmg,user,target)
      return @magnitudeDmg
    end
  
    def pbModifyDamage(damageMult,user,target)
      damageMult *= 2 if target.inTwoTurnAttack?("0CA")   # Dig
      damageMult /= 2 if @battle.field.terrain == :Grassy
      return damageMult
    end
  end

  
