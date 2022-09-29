#! /bin/bash

if [[ $1 ]]
then
  # search database for element
  PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

  # if argument is not a number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # get element with atomic_number
    ELEMENT_REQUESTED=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$1;")
  elif [[ $1 =~ ^[a-zA-Z]+$ ]]
  then
   # get element with name or symbol
   ELEMENT_REQUESTED=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol='$1' OR name='$1';")
  else
    # invalid argument
    echo "The argument you provided is invalid."
  fi

  
  if [[ -z $ELEMENT_REQUESTED ]]
  # if not found
  then
    echo "I could not find that element in the database."
  else
    # display element infos
    echo $ELEMENT_REQUESTED | sed 's/|/ /g' | while read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
    done
  fi
  
else
  # no argument provided
  echo -e "Please provide an element as an argument."
fi