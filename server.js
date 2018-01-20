const express = require('express');
const BodyParser = require('body-parser');
const {exec} = require('child_process');
const fs = require('fs');
const net = require('net');

const app = express();
app.use(BodyParser.json({limit: '50mb'}));

const client = new net.Socket();
client.connect(12345, '127.0.0.1', () => {
  console.log('Connected to lua!');
});

app.use('/sarc', (req, res) => {
  console.log('Got', req.body);

  toMl.write(req.body);

  console.log('Wrote data!');

  const data = fromMl.readSync();

  console.log('Read data: ' + data); 

  res.send({
    response: data
  });

  console.log('sent response');
});

app.use('/quit', (req, res) => {
  console.log('quitting')
  fromMl.close();
  toMl.close();
  process.exit();
});

app.listen(3000);
