#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n ~~~~    Welcome to the number guessing game    ~~~~\n\n"
echo -e "Enter your username:"
read USERNAME

PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME';")
if [[ -z $PLAYER_ID ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
else
  PLAYER_INFOS=$($PSQL "SELECT COUNT(*), MIN(score) FROM scores WHERE player_id=$PLAYER_ID;")
  echo $PLAYER_INFOS | sed 's/|/ /g' | while read TOTAL_GAMES BEST_GAME
  do
    echo -e "\nWelcome back, $USERNAME! You have played $TOTAL_GAMES games, and your best game took $BEST_GAME guesses."
  done
fi


SECRET_NUMBER=$(( (RANDOM % 999) + 1 ))

echo Guess the secret number between 1 and 1000:
read GUESS

NUMBER_OF_GUESSES=1
while [[ $GUESS != $SECRET_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo -e "\nIt's lower than that, guess again:"
    NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo -e "\nIt's higher than that, guess again:"
    NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
  fi
  read GUESS
done

echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

# insert player in database if new player
if [[ -z $PLAYER_ID ]]
then
  INSERT_PLAYER_RESULT=$($PSQL "INSERT INTO players (username) VALUES('$USERNAME');")
  if [[ $INSERT_PLAYER_RESULT == "INSERT 0 1" ]]
  then
    # get new player id
    PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME';")
  fi
fi

# insert score in database
INSERT_SCORE_RESULT=$($PSQL "INSERT INTO scores(player_id, score) VALUES($PLAYER_ID, $NUMBER_OF_GUESSES);")