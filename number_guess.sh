#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# get user info
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")
BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")

# trim whitespace
GAMES_PLAYED=$(echo $GAMES_PLAYED | sed 's/ //g')
BEST_GAME=$(echo $BEST_GAME | sed 's/ //g')

if [[ -z $USER_ID ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$((1 + RANDOM % 1000))

echo "Guess the secret number between 1 and 1000:"
GUESS_COUNT=0

while true
do
  read INPUT

  # validate integer
  if [[ ! $INPUT =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((GUESS_COUNT++))

  if [[ $INPUT -eq $SECRET_NUMBER ]]
  then
    break
  elif [[ $INPUT -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

INSERT_GAME=$($PSQL "INSERT INTO games(number_guesses, user_id) VALUES($GUESS_COUNT, $USER_ID)")
