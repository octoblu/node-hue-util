# Philips

Node module for controlling Philips Hue lights

## Installation

`npm install hue-util`

## Example

```javascript
var HueUtil = require('hue-util');

var app = 'hue-util';
var ipAddress = '192.168.1.15'; // Use the ipAddress of the bridge or null
var username = null;
var hue = new HueUtil(app, ipAddress, username, onUsernameChange);

var options = {
  lightNumber: 0, // Light Number or Group Number
  useGroup: true, // To use group or not
  on: false, // Turn the light on or off
  color: 'red', // TinyColor2 color string  
  transitiontime: // A number to define transitiontime (optional)
  alert: undefined// Alert string (optional)
  effect: undefined // Effect string (optional)
};

// Change the lights
hue.changeLights(options, function(error, response){
  if(error != null) return console.error('Error changing lights', error);
  console.log('Response from changing lights', response);
});

// Check the sensors
hue.checkSensors(function(error, response){
  if(error != null) return console.error('Error checking sensors', error);
  console.log('Response from checking sensors', response);
});

// Check the states of the buttons on a hue button
var sensorName = 'SensorName'; // name of your sensor
hue.checkButtons(sensorName, function(error, response){
  if(error != null) return console.error('Error checking buttons', error);
  console.log('Response from checking buttons', response);
  // To prevent duplicates compare the different between the last state and the current state.
  // Button code will be conversion from the raw button code and will be a number between 1 and 4.
  // Response
  // {state: {...}, button: 1}
});

function onUsernameChange(newUsername){
  username = newUsername;
  // Store the username for future use
  // otherwise you'll be required to press the hue bridge link button again
}
```
