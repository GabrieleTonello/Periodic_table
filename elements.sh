#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument.";
else
  REGEX='^[0-9]+$'
  if  [[ $1 =~ $REGEX ]] # if arg is a number
  then
    # try to get data with atomic_number
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1 ")
  else 
    # try to get data symbol or name
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1' OR name='$1' ")
  fi

  # check the data
  if [[ -z $ATOMIC_NUMBER ]]
  then
    # if not found, exit
    echo -e "I could not find that element in the database."
  else
    # get atomic number, name, symbol, type, mass, melting point and boiling point
    ELEMENT_INFO=$($PSQL "SELECT * FROM elements INNER JOIN  properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER ")
    echo $ELEMENT_INFO | while IFS="|" read TYPE_ID ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MELT_P BOIL_P TYPE
    do 
      echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELT_P celsius and a boiling point of $BOIL_P celsius."
    done
  fi
fi
