# SuddendeathMP
A BeamMP plugin useful for gamemodes such as Hide N' Seek. <br />
Allows for users to start a timer which will trigger a Sudden Death event. <br />
When Sudden Death is activated, all users except for the initiator of the event will honk their horns at random intervals for random periods of time.

## Usage
* /suddendeath or /sd will start a 10-second timer after which Sudden Death will be active for 1 minute.
* /suddendeath {time in minutes} or /sd {time in minutes} will start a timer based on user input, currently the max timer is capped at 30 minutes to stop excessive timer amounts
* /stop will stop suddendeath completely, resetting the timers and stopping the event.

## Keep in mind
Currently the plugin grabs the vehicle that the user is focusing when the event starts (When the first timer has finished).
This means that if a player is focusing on another persons car, their own car won't honk during the event.

## To-do
* Add permissions to commands
* Allow for users to opt-in to events allowing for more flexibility
