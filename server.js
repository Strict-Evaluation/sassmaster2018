const express = require('express');
const BodyParser = require('body-parser');
const {exec} = require('child_process');

const app = express();
app.use(BodyParser.json({limit: '50mb'}));

app.use('/sarc', (req, res) => {
  exec(`echo '${req.text}' >> ml_fifo`, (err, out, stderr) => {
    if (err) {
      console.log('Something broke!', err);
      process.exit();
    }
    res.send({
      response: out
    });
  });
});

app.use('/quit', (req, res) => {
  process.exit();
});

app.listen(3000);
