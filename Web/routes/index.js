var SAY_TO_USER = '<Response><Gather timeout="10" numDigits = "1" finishOnKey="*"><Say>Hello, welcome to MLH Pong ! You get to play a ping pong game using your phone keypad. Press 2 to go up, and 8 to go down  .</Say></Gather></Response>'
var express = require('express');
var router = express.Router();
var mySocket;
var xml = require('xml');
require("twilio-node/lib");

// Your accountSid and authToken from twilio.com/user/account
var accountSid = 'AC8b9da60c81b3b9cbf8bc1df0bc1064e9';
var authToken = "9c2d302bb7a28d47dd395ef38a846557";
var client = require('twilio')(accountSid, authToken);

var http = require('http');

var app = express(); 
var server = http.createServer(app);

var io = require('socket.io').listen(8080);
	
	router.post('/respond', function(req, res) {

		var result_From;
		var result_Digits;
		res.header('Content-Type','text/xml').send(SAY_TO_USER);

		result_From = req.body.From;
		result_Digits = req.body.Digits;

		console.log( result_From + " typed: " + result_Digits);
		
		mySocket.emit('change', {'phone_Number' : result_From, 'number_Pressed' : result_Digits});

});

io.on('connection', function (socket) {
	mySocket = socket;
	console.log('New user');
});

module.exports = router;