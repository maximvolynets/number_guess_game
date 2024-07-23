#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align --quiet -c "
echo "Enter your username:"

read USERNAME
GET_USER=$($PSQL "SELECT * FROM games WHERE name = '$USERNAME'")
if [[ -n $GET_USER ]]
then
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE name = '$USERNAME'")
  BEST_SCORE=$($PSQL "SELECT best_score FROM games WHERE name = '$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_SCORE guesses."
else
  $PSQL "INSERT INTO games(name) VALUES('$USERNAME');"
  echo "Welcome, $USERNAME! It looks like this is your first time here."

fi

echo "Guess the secret number between 1 and 1000:"

SECRET_NUMBER=$(( ($RANDOM % 1000) + 1 ))

GET_USER_INPUT()
{
  while read GUESS && [[ ! $GUESS =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
  done
}

COUNT=0

GET_USER_INPUT

while true
do

  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    ((COUNT++))
    break
  fi

  if [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    ((COUNT++))
    GET_USER_INPUT
  fi

  if [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    ((COUNT++))
    GET_USER_INPUT
  fi

done


$PSQL "UPDATE games SET games_played = games_played + 1 WHERE name = '$USERNAME'"

if [[ -z $BEST_SCORE || $BEST_SCORE -gt $COUNT ]]
then
  $PSQL "UPDATE games SET best_score = $COUNT WHERE name = '$USERNAME'"
fi

echo "You guessed it in $COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
