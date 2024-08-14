@body_data = nil
@head_data = nil
class Pokemon
 def get_head_data
    @species_data.head_pokemon.get_evolutions(true).each do |evo|
         # [new_species, method, parameter, boolean]
         next if evo[3] # Prevolution
         ret = evo
         return ret if ret
         end
    return nil
    end
 def get_body_data
    @species_data.body_pokemon.get_evolutions(true).each do |evo|
         # [new_species, method, parameter, boolean]
         next if evo[3] # Prevolution
         
         ret = evo
         return ret if ret
        
         end
    return nil
    end
 def round_evolevels

    levelpercent = 0
    if @body_data == nil then
      @body_data = get_body_data
      end
    if @head_data == nil then
      @head_data = get_head_data
      end
    echoln @head_data
    if @head_data and @body_data then
      if @head_data[2] < @body_data[2] - 5 or @head_data[2] > @body_data[2] + 4 then
        levelpercent = 0.05
      elsif @head_data[2] <  @body_data[2] - 4 or @head_data[2] >  @body_data[2] + 3 then
          levelpercent = 0.1
      elsif @head_data[2] <  @body_data[2] - 3 or @head_data[2] >  @body_data[2] + 2 then
          levelpercent = 0.15
      elsif @head_data[2] <  @body_data[2] - 2 or @head_data[2] >  @body_data[2] + 1 then
          levelpercent = 0.2
      elsif @head_data[2] <  @body_data[2] - 1 or @head_data[2] > @body_data[2] then
          levelpercent = 0.25
      elsif @head_data[2] ==  @body_data[2] then
          levelpercent = 0.3
      else
        levelpercent = 0
        end
      @head_data[2] +=  @body_data[2] * levelpercent
      @head_data[2] = @head_data[2].round()
      end
  end


 def check_evolution_on_level_up
    if @species_data.is_a?(GameData::FusedSpecies)
      body = self.species_data.body_pokemon
      head = self.species_data.head_pokemon
     if @head_data == nil then
        @head_data = get_head_data
        end
     if @body_data == nil then
        @body_data = get_body_data
        end
     return nil if @body_data[2].is_a?(Symbol)
     return nil if @head_data[2].is_a?(Symbol)
     body_evolution = check_evolution_internal(@species_data.body_pokemon) { |pkmn, new_species, method, parameter|
        success = GameData::Evolution.get(method).call_level_up(pkmn, parameter)
        next (success) ? new_species : nil
      }
     head_evolution = check_evolution_internal(@species_data.head_pokemon) { |pkmn, new_species, method, parameter|
        success = GameData::Evolution.get(method).call_level_up(pkmn, parameter)
        next (success) ? new_species : nil
      }
     current_body = @species_data.body_pokemon
     current_head = @species_data.head_pokemon
     if head_evolution then
       if @head_data[0] != head_evolution
         @head_data = get_head_data
         end
        end

     if @head_data == nil then
        @head_data = get_head_data
        round_evolevels
        end
     if @body_data == nil then
        @body_data = get_body_data
        round_evolevels
        end
    
     if @body_data and body_evolution then
      if @body_data[0] != body_evolution then
         @body_data = get_body_data
         round_evolevels
         end
      end
     round_evolevels
     if @body_data  != nil then
       if @body_data[2] < self.level then
         @body_data = get_body_data
         round_evolevels
         end
       end
     if @head_data  != nil then
      if @head_data[2] < self.level then
        @head_data = get_head_data
        round_evolevels
        end
      end
      
     if @body_data != nil then
       if self.level >= @body_data[2] #EVOLVE BODY
        if body_evolution != nil then
          newspecies = getFusionSpecies(body_evolution, current_head)
          end
        end
       end
     if @head_data != nil then
       if self.level >= @head_data[2] #EVOLVE HEAD
        if head_evolution != nil then
         newspecies = getFusionSpecies(current_body, head_evolution)
         end
        end
       end
     return nil if head_evolution == nil and body_evolution == nil

     if newspecies then
       return newspecies
      end
     @body_data = nil
     @head_data = nil
     return nil
     end
    return check_evolution_internal { |pkmn, new_species, method, parameter|
      success = GameData::Evolution.get(method).call_level_up(pkmn, parameter)
      next (success) ? new_species : nil
      }
    end
end