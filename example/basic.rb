#===============================================================================
# Example :
#-------------------------------------------------------------------------------
# On each map, MY coorditates are the same so I precise them in "Exits:" 
#
# Exits:
#   1: "Right" (15,9)
#   2: "Down" (8,15)
#   3: "Left" (1,9)
#   4: "Up" (8,1)
#
# MapList:
#   1: 
#      name:"Type 1"
#      map_id: 1
#      exits: 1,3
#      mazeEnd: true
#   2: 
#      name:"Type 2"
#      map_id: 5
#      exits: 2,4
#      mazeEnd: false
#   3: 
#      name:"Type 3"
#      map_id: 6
#      exits: 1,2,3,4
#      mazeEnd: false
#   4: 
#      name:"Type 4"
#      map_id: 9
#      exits: 1
#      mazeEnd: true
#   5: 
#      name:"Type 5"
#      map_id: 11
#      exits: 2
#      mazeEnd: true
#   6: 
#      name:"Type 6"
#      map_id: 10
#      exits: 3
#      mazeEnd: true
#   7: 
#      name:"Type 7"
#      map_id: 12
#      exits: 4
#      mazeEnd: false
#   8: 
#      name:"Type 8"
#      map_id: 14
#      exits: 1,2
#      mazeEnd: true
#   9: 
#      name:"Type 9"
#      map_id: 15
#      exits: 2,3
#      mazeEnd: true
#   10: 
#      name:"Type 10"
#      map_id: 16
#      exits: 3,4
#      mazeEnd: false
#   11: 
#      name:"Type 11"
#      map_id: 17
#      exits: 4,1
#      mazeEnd: false
#===============================================================================

#=begin

print "\
=====================================\n\
Setting up the default maze propeties\n\
=====================================\
"

$Maze = Maze.new

$Maze.new_exit(3,"R")
$Maze.new_exit(4,"D")
$Maze.new_exit(1,"L")
$Maze.new_exit(2,"U")

print "\n\nExits:\n\n",$Maze.exits


exit_right =  {
                "id"=>1,
                "x"=>15,
                "y"=>9
              }

exit_down =   {
                "id"=>2,
                "x"=>8,
                "y"=>15
              }

exit_left =   {
                "id"=>3,
                "x"=>1,
                "y"=>9
              }


exit_up =     {
                "id"=>4,
                "x"=>8,
                "y"=>1
              }


$Maze.new_map_type("Type 1",1,[exit_right,exit_left],true)
$Maze.new_map_type("Type 2",5,[exit_up,exit_down],false)
$Maze.new_map_type("Type 3",6,[exit_right,exit_left,exit_up,exit_down],false)
$Maze.new_map_type("Type 4",9,[exit_right],true)
$Maze.new_map_type("Type 5",11,[exit_down],true)
$Maze.new_map_type("Type 6",10,[exit_left],true)
$Maze.new_map_type("Type 7",12,[exit_up],false)
$Maze.new_map_type("Type 8",14,[exit_right,exit_down],true)
$Maze.new_map_type("Type 9",15,[exit_down,exit_left],true)
$Maze.new_map_type("Type 10",16,[exit_up,exit_left],false)
$Maze.new_map_type("Type 11",17,[exit_right,exit_up],false)

print "\n\n\n",$Maze.mapList

#=end
