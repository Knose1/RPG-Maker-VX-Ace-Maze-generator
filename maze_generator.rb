#From Command 201
def teleport_hero(map_id, x=0, y=0, dir=0, fade=0)
  return if $game_party.in_battle
  
  $game_player.reserve_transfer(map_id, x, y, dir)
  $game_temp.fade_type = fade
  Fiber.yield while $game_player.transfer?
  
end

#===============================================================================
# Random Maze Generator (using repititives maps)
#-------------------------------------------------------------------------------
# Warning: This class (and the functions in it) don't handle error !
#
# Don't forget to create map_types with 1 exit !
#===============================================================================

class Maze

  #=============================================================================
  # Define a new exit type, common exits are Left,Down,Right,Up
  #=============================================================================
  
  def new_exit(goto,alter)
    
    @exitsAlias = self.exits
    
    if (@exitsAlias.length == 0)
      @exitsAlias[@exitsAlias.length + 1] = {
                                              "goto"=>goto,
                                              "id"=>@exitsAlias.length + 1,
                                              "alias"=>alter
                                            }
    else
      @exitsAlias[@exitsAlias.length] = {
                                          "goto"=>goto,
                                          "id"=>@exitsAlias.length,
                                          "alias"=>alter
                                        }
    end
  end
  
  #=============================================================================
  # Define a new map type
  #-----------------------------------------------------------------------------
  # * exits:
  #   [
  #     {
  #       "id"=>exit_id,
  #       "x"=>x_for_teleport,
  #       "y"=>y_for_teleport
  #     },
  #     {
  #       "id"=>exit_id,
  #       "x"=>x_for_teleport2,
  #       "y"=>y_for_teleport2
  #     }
  #   ]
  #=============================================================================
  
  def new_map_type(name,map_id,exits,enableMazeEnd)
    
    @mapListAlias = self.mapList
    
    if (@mapListAlias.length == 0)
      @mapListAlias[@mapListAlias.length + 1] = {
                                                  "name"=>name,
                                                  "id"=>map_id,
                                                  "exits"=>exits,
                                                  "mazeEnd"=>enableMazeEnd
                                                }
    else
      @mapListAlias[@mapListAlias.length] = {
                                              "name"=>name,
                                              "id"=>map_id,
                                              "exits"=>exits,
                                              "mazeEnd"=>enableMazeEnd
                                            }
    end
    
  
  end

  #=============================================================================
  # Generate the maze
  #-----------------------------------------------------------------------------
  # * WARNING: this function teleport the Hero to the start room of the maze
  #
  # * startCoordinates:
  #   {
  #     "x"=>x
  #     "y"=>y
  #   }
  #
  # * "max" determinate the number of room with > 1 exits that can be used.
  #
  # * startType: the id inside @mapListAlias.
  #   When we do @mapListAlias[startType] we must find a map type
  #
  # * events is used to add datas to one or more areas, a filter can be applied
  # on map types to add the event(s) on a random area matching the filter. For example the event
  # Exit (can't be removed) search for the property mazeEnd
  #
  #    - The filter is an array of string. Each string is a property
  # of the map type: if you setup for example "filter"=>["!mazeEnd"] it will find all
  # maze with mazeEnd == false or mazeEnd == nil
  #   Use "filter"=>"*" if you don't wants to apply a filter.
  #
  #    - Count: how many must be filtered
  #    - required: does the maze absolutely need it ?
  #
  #   [
  #     {
  #       "filter"=>filter,
  #       "count"=>Number,
  #       "required"=>Boolean,
  #     },
  #     {
  #       "filter"=>filter2,
  #       "count"=>Number2,
  #       "required"=>Boolean2,
  #     }
  #     Add More if needed
  #   ]
  #=============================================================================
  
  def generate_maze(max,startCoordinates,startType,doTeleport = true,events=nil)
  
  # maze generation
  @mazeAlias = []
  
  @mazeAreaAlias = 1
  
  @mapListAlias = self.mapList
  
  
  #----
  
  roomsWithEnd = [] #RWE
  
  i = 0
  while (i < @mapListAlias.length - 1)
    
    i += 1
    
    if (@mapListAlias[i]["mazeEnd"])
      l = roomsWithEnd.length
      roomsWithEnd[l] = @mapListAlias[i]
      roomsWithEnd[l]["mapListId"] = i 
    end
    
  end
  
  #----
  
  roomsWithOneExit = []
  roomsWithMoreThanOneExit = []
  
  i = 0
  while (i < @mapListAlias.length - 1)
    
    i+=1
    
    if (@mapListAlias[i]["exits"].length > 1)
      l = roomsWithMoreThanOneExit.length
      roomsWithMoreThanOneExit[l] = @mapListAlias[i]
      roomsWithMoreThanOneExit[l]["mapListId"] = i
    else
      l = roomsWithOneExit.length
      roomsWithOneExit[l] = @mapListAlias[i]
      roomsWithOneExit[l]["mapListId"] = i
    end
    
  end
  
  #----
  
  #On génère la map tant qu'il n'y a pas de fin de dongeon ou jusqu'à ce que 2 boucles soient faites
  
  haveEnd = false
  loopCount = 0
  
  while (!haveEnd or loopCount < 2)
    loopCount += 1
      
    #----
    @mazeAlias = []
    @mazeAlias[1] = {"type"=>startType}
    
    
    #i = -1
    
    #while (i < @mapListAlias[startType]["exits"].length - 1)
    #  i += 1
    #  @mazeAlias[1][ @mapListAlias[startType]["exits"][i]["id"].to_s ] = i + 2
    #end
    
    #----
  
  

    
    
    totalParts = 1
    i = 0
    
    while (totalParts < max)
      i += 1
      
      #On récupère les object exit de la map @mazeAlias[i] grâce à son type
      for exitMapObject in @mapListAlias[ @mazeAlias[i]["type"] ]["exits"]

        print "\n\n\n@mazeAlias[i] :", @mazeAlias[i]
        print "\ni :", i

        if (exitMapObject != nil)
        #On vérifie que l'on peux crée un bloc
          if (totalParts < max)
            
            
            #{exitId => exitMap}
            exitId = exitMapObject["id"].to_s
            print "\nexitId :", exitId

            #On récupère l'id de la map de sortie
            if (@mazeAlias[i][exitId] == nil or @mazeAlias[i][exitId] <= 0)
              @mazeAlias[i][exitId] = @mazeAlias.length
            end
            exitMap = @mazeAlias[i][exitId]
            
            if (exitMap > i)

              @mazeAlias[exitMap] = {}
              totalParts += 1
              
              bloqueCompatible = false
              while (!bloqueCompatible)
                #on récupère une map random qui n'es pas une impasse
                myRandNumber = rand( roomsWithMoreThanOneExit.length)
                randMazeExit = roomsWithMoreThanOneExit[myRandNumber]
                
                
                #on récupère l'id
                @mazeAlias[exitMap]["type"] = randMazeExit["mapListId"].to_i
                
                #on récupère le goto de la map @mazeAlias[i]
                #    @exitsAlias[exitId.to_i]["goto"]
                
                #on regarde s'il y a une exit avec l'id du goto, si oui on set @mazeAlias[exitMap] par "i"
                for exitMapObject2 in @mapListAlias[ @mazeAlias[exitMap]["type"] ]["exits"]
                  if(exitMapObject2["id"] == @exitsAlias[exitId.to_i]["goto"] and !bloqueCompatible)
                    bloqueCompatible = true
                    @mazeAlias[exitMap][@exitsAlias[exitId.to_i]["goto"].to_s] = i
                  end
                end
              end
            end
          end
        end
      end
    end
    
    #On comble les trous avec des impasses
    i = 0
    while i < @mazeAlias.length - 1
      i += 1
      for mapExit in @mapListAlias[@mazeAlias[i]["type"]]["exits"]
        if (mapExit != nil)
          #on regarde si la direction n'est pas set
          if (@mazeAlias[i][mapExit["id"].to_s] == nil)
            #on créer la nouvelle map
            l = @mazeAlias.length
            @mazeAlias[i][mapExit["id"].to_s] = l 
            @mazeAlias[l] = {}

            #on cherche l'impasse avec le goto qui correspond à l'exit de la room
            for oneExitRoom in roomsWithOneExit
              if (@exitsAlias[mapExit["id"].to_i]["goto"] == oneExitRoom["exits"][0]["id"])
                @mazeAlias[l]["type"] = oneExitRoom["mapListId"]
                @mazeAlias[l][@exitsAlias[mapExit["id"]]["goto"].to_s] = i
              end
            end
          end
        end
      end
    end
    
    allPossibleEnd = []

    #on check s'il existe une exit
    i = 1
    while i < @mazeAlias.length - 1
      i += 1
      #on récupère la mapType object
        if (@mapListAlias[@mazeAlias[i]["type"]]["mazeEnd"])
          haveEnd = true
          allPossibleEnd[allPossibleEnd.length] = i
        end
    end

    print "\n\n------------------------\nallPossibleEnd: ",allPossibleEnd

    #on choisie une exit random
    print "\n\n@mazeExitIdAlias: ",@mazeExitIdAlias = allPossibleEnd[rand(allPossibleEnd.length).to_i]
  end
  
  
  #----
  
  if (!haveEnd)
    return print "Max loop in generate_maze()"
  end
  
  print "\n\n Maze:",@mazeAlias
  
      #Use switchs to see if you are in the starting room OR in the end room OR anywhere else 
      
        # Switch Start Area
          $game_switches[3] = true
        
        # Switch End Area
          $game_switches[4] = false
          
    if (doTeleport == true)
      teleport_hero(@mapListAlias[startType]["id"],startCoordinates["x"],startCoordinates["y"])
    end    
    return
  end
  
  #=============================================================================
  # Teleport from a map of the maze to another map of the maze
  #=============================================================================
  
  def maze_teleport(exiting)
    
    print "\n\n\n------------------"
    
    exiting_bef = exiting

    @exitsAlias = self.exits
    
    if (exiting.class == String)
      i = 0
      while (i < @exitsAlias.length - 1)
        i+=1
        if (@exitsAlias[i]["alias"] == exiting)

          exiting = @exitsAlias[i]["id"].to_s

          break
        end
      end
      
      if (exiting == exiting_bef)
        return print "\n\nERROR: Maze.teleport(), #{exiting} is not an exit"
      end
    end  
    
    print "\n\n\nexiting: ",exiting
    
    @mapListAlias = self.mapList #les room
    @mazeAlias = self.maze #le maze
    
    @mazeExitIdAlias = self.maze_exit_id #sortie
    @mazeAreaAlias = self.maze_area #où je suis
    
    
    mapInt = @mazeAlias[@mazeAlias[@mazeAreaAlias.to_i][exiting.to_s].to_i]["type"].to_i
    mapId = @mapListAlias[
                mapInt
            ]["id"]
    
    x_and_y_founded = false
    i = -1
    while (i < @mapListAlias[mapInt]["exits"].length - 1)
      i += 1
      print "\n\n",@mapListAlias[mapInt]["exits"][i]["id"],"/",@exitsAlias[exiting.to_i]["goto"]
      if (@mapListAlias[mapInt]["exits"][i]["id"] == @exitsAlias[exiting.to_i]["goto"])
        x =  @mapListAlias[mapInt]["exits"][i]["x"]
        y =  @mapListAlias[mapInt]["exits"][i]["y"]
        x_and_y_founded = true
        break
      end
    end
    
    if(x_and_y_founded == false)
      return print "\n\nERROR: Maze.teleport(), #{exiting_bef} is a wrong exit"
    end
    
    print "\n\n\nx,y: ",x,",",y
    
    @mazeAreaAlias = @mazeAlias[@mazeAreaAlias.to_i][exiting.to_s].to_i
    print "\n\n\nTo: ",@mazeAreaAlias
    
    teleport_hero(mapId,x,y)
    
    #Use switchs to see if you are in the starting room OR in the end room OR anywhere else 
    
      # Switch Start Area
        $game_switches[3] = (@mazeAreaAlias == 1)
          
      # Switch End Area
        $game_switches[4] = (@mazeAreaAlias == @mazeExitIdAlias)
      
  end
  
  #=============================================================================
  # Used to output the @var
  #=============================================================================
  
  def exits
    return @exitsAlias || []
  end

  def mapList
    return @mapListAlias || []
  end

  def maze
    return @mazeAlias || []
  end
  
  def maze_area
    return @mazeAreaAlias || -1
  end
  
  def maze_exit_id
    return @mazeExitIdAlias || -1
  end
  
  def events
    return @events
  end
end
