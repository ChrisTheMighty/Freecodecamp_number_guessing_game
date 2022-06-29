#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c"

echo -e "\nEnter your username:\n"
read USERNAME
EXISTING_USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
if ! [[ -z $EXISTING_USERNAME ]]
then
  GAMES_PLAYED=$($PSQL "SELECT number_of_games FROM user_stats WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game_number_of_guesses FROM user_stats WHERE user_id= $USER_ID")
  echo "Welcome back, $EXISTING_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  while [[ ${#USERNAME} -gt 30 ]]
  do
    echo "Username cannot exceed 30 characters. Please enter a valid username."
    read USERNAME
  done
  USER_INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  if [[ $USER_INSERT_RESULT == "INSERT 0 1" ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
    CREATE_USER_STATS_ENTRY=$($PSQL "INSERT INTO user_stats(user_id, number_of_games, best_game_number_of_guesses) VALUES($USER_ID, 0, 0)")
  fi
fi

NUMBER=$(( $RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"
read GUESS
let COUNT=0

until [[ $GUESS == $NUMBER ]]
do

  while ! [[ $GUESS =~ ^[0-9]*$ ]]
  do
    echo "That is not an integer, guess again:"
    read GUESS
  done

  if [[ $GUESS -gt $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read GUESS
    let COUNT++
  else
    echo "It's higher than that, guess again:"
    read GUESS
    let COUNT++
  fi
done

let COUNT++
echo "You guessed it in $COUNT tries. The secret number was $NUMBER. Nice job!"
INCREMENT_NUMBER_OF_GAMES=$($PSQL "UPDATE user_stats SET number_of_games = number_of_games+1 WHERE user_id = $USER_ID")
UPDATE_BEST_GAME=$($PSQL "UPDATE user_stats SET best_game_number_of_guesses = $COUNT WHERE (best_game_number_of_guesses > $COUNT OR best_game_number_of_guesses = 0) AND user_id = $USER_ID")
